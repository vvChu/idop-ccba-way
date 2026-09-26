"""Tests for IDOP SharePoint List Schema Validator and Pydantic Models."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from tools.validator.models import (
    CDEDocumentsItem,
    ContractsItem,
    EmployeesItem,
    OpportunitiesItem,
    SubmissionsItem,
)
from tools.validator.schema_validator import (
    load_list_definitions,
    load_taxonomy_termsets,
    validate_column_semantics,
    validate_datamodel,
)


@pytest.fixture
def repo_root() -> Path:
    """Fixture returning absolute repository root directory."""
    return Path(__file__).resolve().parents[1]


@pytest.fixture
def lists_dir(repo_root: Path) -> Path:
    """Fixture returning lists directory."""
    return repo_root / "datamodel" / "sharepoint" / "lists"


@pytest.fixture
def tax_dir(repo_root: Path) -> Path:
    """Fixture returning taxonomy directory."""
    return repo_root / "datamodel" / "sharepoint" / "taxonomy"


@pytest.fixture
def meta_schema_path(repo_root: Path) -> Path:
    """Fixture returning meta-schema path."""
    return repo_root / "datamodel" / "sharepoint" / "schemas" / "sp-list.schema.json"


# =============================================================================
# POSITIVE TESTS
# =============================================================================


def test_all_59_lists_valid_draft07(
    lists_dir: Path, tax_dir: Path, meta_schema_path: Path
) -> None:
    """Ensures all 59 SharePoint lists pass Draft-07 and semantic validation."""
    count, errors = validate_datamodel(lists_dir, tax_dir, meta_schema_path)
    assert count == 59, f"Expected 59 lists, but found {count}"
    assert len(errors) == 0, f"Found {len(errors)} validation errors: {errors}"


def test_taxonomy_cross_reference_integrity(lists_dir: Path, tax_dir: Path) -> None:
    """Ensures all ManagedMetadata fields point to existing taxonomy files."""
    known_tax = load_taxonomy_termsets(tax_dir)
    assert len(known_tax) >= 21

    raw_lists = load_list_definitions(lists_dir)
    unique_lists = {path: data for path, data in raw_lists.values()}

    for file_path, data in unique_lists.items():
        list_name = data.get("ListName", file_path.stem)
        for col in data.get("Columns", []):
            if col.get("Type") in ("ManagedMetadata", "Taxonomy"):
                term_name = col.get("TermSet", {}).get("Name")
                assert term_name in known_tax, (
                    f"List {list_name} column {col.get('Name')} references unknown TermSet '{term_name}'"
                )


def test_lookup_cross_reference_integrity(lists_dir: Path) -> None:
    """Ensures all Lookup fields point to valid lists in datamodel."""
    raw_lists = load_list_definitions(lists_dir)
    known_lists = set(raw_lists.keys())

    unique_lists = {path: data for path, data in raw_lists.values()}
    for file_path, data in unique_lists.items():
        list_name = data.get("ListName", file_path.stem)
        for col in data.get("Columns", []):
            if col.get("Type") == "Lookup":
                target_list = col.get("Lookup", {}).get("List")
                assert target_list in known_lists, (
                    f"List {list_name} column {col.get('Name')} references unknown Lookup list '{target_list}'"
                )


def test_submissions_has_cde_document(lists_dir: Path) -> None:
    """Verifies submissions.json contains CDEDocument in RelatedEntity Choices."""
    submissions_path = lists_dir / "system_governance" / "submissions.json"
    assert submissions_path.is_file()

    data = json.loads(submissions_path.read_text(encoding="utf-8"))
    col = next((c for c in data.get("Columns", []) if c.get("Name") == "RelatedEntity"), None)
    assert col is not None
    assert "CDEDocument" in col.get("Choices", [])


def test_generated_pydantic_models() -> None:
    """Verifies that generated models instantiate properly with aliases and snake_case."""
    # 1. SubmissionsItem
    sub = SubmissionsItem(
        SubmissionTitle="Phê duyệt bản vẽ CDE",
        RelatedEntity="CDEDocument",
        RelatedId=42,
    )
    assert sub.submission_title == "Phê duyệt bản vẽ CDE"
    assert sub.related_entity == "CDEDocument"
    assert sub.related_id == 42

    # 2. CDEDocumentsItem
    cde = CDEDocumentsItem(
        ProjectCode="DA-2026-01",
        Originator="CCBA",
        ZoneVolume="ZZ",
        LevelLocation="01",
        DocumentCode="DR-001",
        ApprovalStatus="S0",
    )
    assert cde.project_code == "DA-2026-01"
    assert cde.approval_status == "S0"

    # 3. OpportunitiesItem
    opp = OpportunitiesItem(
        opportunity_name="Tư vấn BIM Bệnh viện",
        stage="New",
        risk_flags=None,
    )
    assert opp.opportunity_name == "Tư vấn BIM Bệnh viện"
    assert opp.stage == "New"
    assert opp.risk_flags is None

    # 4. ContractsItem & EmployeesItem
    contract = ContractsItem(ContractCode="HD-2026/01", GrossAmount=1500000000)
    assert contract.contract_code == "HD-2026/01"
    assert contract.gross_amount == 1500000000

    emp = EmployeesItem(EmployeeCode="CCBA-001", FullName="Nguyễn Văn A")
    assert emp.employee_code == "CCBA-001"
    assert emp.full_name == "Nguyễn Văn A"


# =============================================================================
# NEGATIVE TESTS
# =============================================================================


def test_invalid_schema_structure_fails(
    tmp_path: Path, tax_dir: Path, meta_schema_path: Path
) -> None:
    """Verifies validator rejects files missing required ListName or with invalid Type."""
    bad_list_dir = tmp_path / "bad_lists"
    bad_list_dir.mkdir()

    # Missing ListName
    (bad_list_dir / "bad_schema.json").write_text(
        json.dumps({
            "Columns": [{"Name": "Title", "Type": "Text"}]
        }),
        encoding="utf-8",
    )

    count, errors = validate_datamodel(bad_list_dir, tax_dir, meta_schema_path)
    assert count == 1
    assert len(errors) > 0
    assert any("ListName" in err for err in errors)


def test_broken_lookup_reference_fails() -> None:
    """Verifies validator flags lookup targeting non-existent list."""
    col = {
        "Name": "BadLookup",
        "Type": "Lookup",
        "Lookup": {"List": "NonExistentGhostList", "Field": "ID"},
    }
    known_lists = {"Projects", "Contracts"}
    known_tax = {"CCBA_TrangThaiPheDuyet"}

    errors = validate_column_semantics("TestList", col, known_lists, known_tax)
    assert len(errors) == 1
    assert "NonExistentGhostList" in errors[0]


def test_broken_taxonomy_reference_fails() -> None:
    """Verifies validator flags ManagedMetadata targeting non-existent TermSet."""
    col = {
        "Name": "BadTaxonomy",
        "Type": "ManagedMetadata",
        "TermSet": {"Group": "CCBA Taxonomy", "Name": "NonExistentGhostTermSet"},
    }
    known_lists = {"Projects"}
    known_tax = {"CCBA_TrangThaiPheDuyet"}

    errors = validate_column_semantics("TestList", col, known_lists, known_tax)
    assert len(errors) == 1
    assert "NonExistentGhostTermSet" in errors[0]
