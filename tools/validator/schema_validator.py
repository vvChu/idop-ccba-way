"""SharePoint List Schema & Taxonomy Validator for IDOP-CCBA-WAY.

Validates 59 SharePoint List schemas against Draft-07 meta-schema and enforces
semantic integrity for Lookups, ManagedMetadata (Taxonomy), and Choice fields.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

import jsonschema


def load_taxonomy_termsets(tax_dir: Path) -> set[str]:
    """Loads valid Taxonomy TermSet names from taxonomy directory.

    Args:
        tax_dir: Path to datamodel/sharepoint/taxonomy directory.

    Returns:
        Set of valid TermSet names (both TermSetInfo.Name and filename stem).
    """
    tax_names: set[str] = set()
    if not tax_dir.is_dir():
        return tax_names

    for file_path in sorted(tax_dir.glob("*.json"), key=lambda p: p.as_posix()):
        try:
            data = json.loads(file_path.read_text(encoding="utf-8"))
            name = data.get("TermSetInfo", {}).get("Name")
            if name:
                tax_names.add(str(name))
            tax_names.add(file_path.stem)
        except (json.JSONDecodeError, OSError):
            continue

    return tax_names


def load_list_definitions(lists_dir: Path) -> dict[str, tuple[Path, dict[str, Any]]]:
    """Loads all SharePoint List JSON files and maps list identifiers.

    Args:
        lists_dir: Path to datamodel/sharepoint/lists directory.

    Returns:
        Dict mapping list identifier (both ListName and stem) to (Path, data).
    """
    list_map: dict[str, tuple[Path, dict[str, Any]]] = {}
    if not lists_dir.is_dir():
        return list_map

    for file_path in sorted(lists_dir.rglob("*.json"), key=lambda p: p.as_posix()):
        try:
            data = json.loads(file_path.read_text(encoding="utf-8"))
            list_name = data.get("ListName")
            if list_name:
                list_map[str(list_name)] = (file_path, data)
            list_map[file_path.stem] = (file_path, data)
        except (json.JSONDecodeError, OSError):
            continue

    return list_map


def validate_column_semantics(
    list_name: str,
    col: dict[str, Any],
    known_lists: set[str],
    known_tax: set[str],
) -> list[str]:
    """Validates semantic integrity constraints of a single column.

    Args:
        list_name: The parent list name.
        col: Column dictionary definition.
        known_lists: Set of valid list names for lookup targets.
        known_tax: Set of valid taxonomy term set names.

    Returns:
        List of error strings found in column.
    """
    errors: list[str] = []
    col_name = col.get("Name", "<unnamed>")
    col_type = col.get("Type", "")

    if col_type == "Lookup":
        target_list = col.get("Lookup", {}).get("List")
        if not target_list:
            errors.append(f"{list_name}.{col_name}: Lookup missing target 'List'")
        elif target_list not in known_lists:
            errors.append(
                f"{list_name}.{col_name}: Lookup target list '{target_list}' not found"
            )

    if col_type in ("ManagedMetadata", "Taxonomy"):
        target_term = col.get("TermSet", {}).get("Name")
        if not target_term:
            errors.append(f"{list_name}.{col_name}: ManagedMetadata missing TermSet 'Name'")
        elif target_term not in known_tax:
            errors.append(
                f"{list_name}.{col_name}: TermSet '{target_term}' not found in taxonomy"
            )

    if col_type in ("Choice", "MultiChoice"):
        choices = col.get("Choices")
        if not choices or not isinstance(choices, list) or len(choices) == 0:
            errors.append(f"{list_name}.{col_name}: {col_type} has empty or missing Choices")

    return errors


def validate_datamodel(
    lists_dir: Path,
    tax_dir: Path,
    meta_schema_path: Path,
    only_list: str | None = None,
) -> tuple[int, list[str]]:
    """Performs full Draft-07 and semantic validation on list datamodels.

    Args:
        lists_dir: Directory containing list definitions.
        tax_dir: Directory containing taxonomy term sets.
        meta_schema_path: Path to sp-list.schema.json.
        only_list: Optional list name filter.

    Returns:
        Tuple of (validated_count, list_of_error_strings).
    """
    if not meta_schema_path.is_file():
        return 0, [f"Meta-schema file not found: {meta_schema_path}"]

    try:
        meta_schema = json.loads(meta_schema_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as exc:
        return 0, [f"Failed to read meta-schema: {exc}"]

    known_tax = load_taxonomy_termsets(tax_dir)
    raw_list_map = load_list_definitions(lists_dir)
    known_lists = set(raw_list_map.keys())

    # De-duplicate to unique files
    unique_files: dict[Path, dict[str, Any]] = {
        path: data for path, data in raw_list_map.values()
    }

    all_errors: list[str] = []
    validated_count = 0

    for file_path in sorted(unique_files.keys(), key=lambda p: p.as_posix()):
        data = unique_files[file_path]
        list_name = data.get("ListName", file_path.stem)

        if only_list and only_list not in (list_name, file_path.stem):
            continue

        validated_count += 1

        # 1. Draft-07 JSON Schema validation
        try:
            jsonschema.validate(instance=data, schema=meta_schema)
        except jsonschema.ValidationError as err:
            all_errors.append(f"[{list_name}] Schema violation: {err.message}")

        # 2. Semantic checks for columns
        for col in data.get("Columns", []):
            col_errs = validate_column_semantics(list_name, col, known_lists, known_tax)
            all_errors.extend(col_errs)

    return validated_count, all_errors


def main() -> int:
    """CLI entrypoint for schema validator."""
    parser = argparse.ArgumentParser(
        description="Validate IDOP SharePoint List schemas against Draft-07 meta-schema and semantic rules."
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path("."),
        help="Root repository directory (default: current directory).",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Display detailed inspection progress.",
    )
    parser.add_argument(
        "--only",
        type=str,
        default=None,
        help="Validate only a specific list name or file stem.",
    )

    args = parser.parse_args()
    repo_root = args.root.resolve()
    lists_dir = repo_root / "datamodel" / "sharepoint" / "lists"
    tax_dir = repo_root / "datamodel" / "sharepoint" / "taxonomy"
    schema_file = repo_root / "datamodel" / "sharepoint" / "schemas" / "sp-list.schema.json"

    count, errors = validate_datamodel(
        lists_dir=lists_dir,
        tax_dir=tax_dir,
        meta_schema_path=schema_file,
        only_list=args.only,
    )

    if args.verbose:
        print(f"Validated {count} list definition(s) across {lists_dir.as_posix()}.")

    if errors:
        print(f"❌ Found {len(errors)} validation error(s):")
        for err in errors:
            print(f"  - {err}")
        return 1

    print(f"✅ All {count} SharePoint list schema(s) passed validation.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
