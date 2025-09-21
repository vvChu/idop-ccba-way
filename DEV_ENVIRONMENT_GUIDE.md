# DEVELOPER ENVIRONMENT SETUP GUIDE

**IDOP-CCBA-WAY Development Environment**

## 🎯 Prerequisites

### Required Software

- **PowerShell 7+**: Core scripting environment
- **Node.js 18+**: For validation scripts and tools
- **Git**: Version control
- **VS Code**: Recommended IDE with extensions:
  - PowerShell
  - JSON
  - Markdown All in One
  - GitLens

### Required Accounts & Permissions

- **GitHub**: Access to idop-ccba-way repository
- **SharePoint**: Access to Dev/Test environments
- **Power Platform**: Developer environment access

## 🚀 Quick Start (15 minutes)

### Step 1: Clone Repository

```powershell
# Clone the repo
git clone https://github.com/vvChu/idop-ccba-way.git
cd idop-ccba-way

# Verify structure
Get-ChildItem -Directory
```

### Step 2: Environment Configuration

```powershell
# Copy and configure environment
Copy-Item .env.example .env
# Edit .env with your environment details
notepad .env
```

### Step 3: Validate Setup

```powershell
# Test schema validation
node tools/scripts/validate-sp-schemas.js

# Test PowerShell scripts (dry-run)
.\tools\scripts\apply-sp-lists.ps1 -Environment Dev -DryRun

# Check markdown linting
npx markdownlint-cli --config .markdownlint.json .
```

## 📚 Understanding the Structure

### Key Directories

```
idop-ccba-way/
├── datamodel/sharepoint/     # SharePoint lists & schemas
├── specs/modules/            # Module specifications
├── tools/scripts/           # Deployment & utility scripts
├── .github/workflows/       # CI/CD pipelines
├── prompts/                 # AI prompts for development
└── docs/                   # Documentation
```

### Important Files

- **AGENTS.md**: AI Agent guidelines
- **constitution.md**: Technical principles & quality control
- **README.md**: Project overview
- **.env**: Environment configuration

## 🔧 Development Workflow

### 1. Working with Modules

```powershell
# Generate new module documentation
# Use prompts/spec.md, prompts/plan.md, prompts/tasks.md as guides

# Example: Create new module in specs/modules/new_module/
mkdir specs/modules/new_module
# Copy templates and customize
```

### 2. SharePoint Development

```powershell
# Add new list definition
# Create JSON in datamodel/sharepoint/lists/category/

# Validate schema
node tools/scripts/validate-sp-schemas.js

# Deploy to Dev
.\tools\scripts\apply-sp-lists.ps1 -Environment Dev
```

### 3. Testing & Validation

```powershell
# Run all validations
npx markdownlint-cli --config .markdownlint.json .
node tools/scripts/validate-sp-schemas.js

# Test deployment (dry-run)
.\tools\scripts\apply-sp-lists.ps1 -Environment Dev -DryRun
```

## 🎓 First Development Exercise

### Exercise: Add a simple SharePoint list

1. **Create list definition** in `datamodel/sharepoint/lists/test/`
2. **Validate schema** with validation script
3. **Deploy to Dev** environment
4. **Verify in SharePoint** that list was created

### Example List JSON:

```json
{
  "title": "Test Items",
  "description": "Test list for development training",
  "fields": [
    {
      "name": "Title",
      "type": "Text",
      "required": true
    },
    {
      "name": "Description", 
      "type": "Note",
      "required": false
    }
  ]
}
```

## 🤝 Team Development Standards

### Git Workflow

1. Create feature branch: `git checkout -b feature/module-name`
2. Make changes and commit: `git commit -m "feat: description"`
3. Push and create PR: `git push origin feature/module-name`
4. Code review and merge

### Documentation Standards

- Follow markdown linting rules
- Update module specs when changing functionality
- Use prompts for consistency

### Quality Checks

- All changes must pass CI/CD pipeline
- Schema validation required
- Markdown linting enforced

## 🆘 Troubleshooting

### Common Issues

- **PowerShell execution policy**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **Node.js version**: Use Node 18+ for compatibility
- **SharePoint permissions**: Ensure proper site access

### Getting Help

- Check `AGENTS.md` for AI Agent guidelines
- Review `constitution.md` for technical principles
- Use GitHub Issues for bug reports
- Join team channels for real-time support

---
**Ready to contribute to IDOP-CCBA-WAY! 🚀**