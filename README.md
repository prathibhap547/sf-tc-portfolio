# Salesforce CI/CD DevOps Pipeline with SFDX + GitHub Actions

Complete production-ready CI/CD pipeline demonstrating enterprise deployment patterns. Feature branches → automated Jest + Apex tests → staging deployment with manual approval gates.

## 🎯 Why This Matters

Interview-winning pattern:
- ❌ "We use change sets" (junior mindset)
- ✅ "Git-based CI/CD with automated test gates on every PR" (senior mindset)

This project covers every part of that story.

## 📋 Architecture Overview

```
Developer → git push feature/my-change
    ↓
GitHub Pull Request opened
    ├─────────────────────────────────┐
    ↓                                 ↓
Job 1: LWC Jest Tests          Job 2: Apex Validation
  (~2 min, Node 18)            (~15 min on scratch org)
  - npm test                    - Create fresh scratch org
  - Check coverage              - Deploy all metadata
                                - Run all Apex tests
    │                           - Assert ≥85% coverage
    └─────────┬─────────────────┘
              ↓
        Both must pass
              ↓
        PR can be merged to main
              ↓
        auto-triggered on merge
              ↓
        Job 3: Deploy to Staging
              ↓
        Manual approval gate
              ↓
        Job 4: Deploy to Production
```

## 🚀 Quick Start

### Prerequisites

```bash
# Install Salesforce CLI
npm install -g @salesforce/cli

# Or with yarn
yarn global add @salesforce/cli

# Verify installation
sf version
```

### Setup Steps

#### 1. Clone & Initialize

```bash
git clone <your-repo>
cd sf-tc-portfolio
npm install
```

#### 2. Create Dev Hub Authorization

```bash
# Log in with your Salesforce Developer Edition
sf org login web --set-default-dev-hub --alias DevHub

# Verify Dev Hub is set
sf org list --all
```

#### 3. Create Scratch Org for Development

```bash
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias dev \
  --duration-days 30 \
  --set-default

# Open scratch org in browser
sf org open
```

#### 4. Deploy Metadata to Scratch Org

```bash
sf project deploy start --source-dir force-app
```

#### 5. Run Tests Locally

```bash
# Apex tests on scratch org
sf apex run test \
  --target-org dev \
  --test-level RunLocalTests \
  --code-coverage

# LWC Jest tests
npm test
```

## 📁 Project Structure

```
sf-tc-portfolio/
├── force-app/
│   └── main/
│       └── default/
│           ├── classes/
│           │   ├── CaseAgentActions.cls
│           │   ├── CaseAgentActions.cls-meta.xml
│           │   ├── CaseAgentActionsTest.cls
│           │   └── CaseAgentActionsTest.cls-meta.xml
│           └── lwc/
│               └── caseSearch/
│                   ├── caseSearch.html
│                   ├── caseSearch.js
│                   ├── caseSearch.js-meta.xml
│                   └── __tests__/
│                       └── caseSearch.test.js
├── config/
│   └── project-scratch-def.json
├── .github/
│   └── workflows/
│       └── ci.yml                    ← Pipeline config
├── sfdx-project.json
├── package.json
└── README.md
```

## 🔧 Pipeline Setup on GitHub

### Step 1: Generate Auth URLs

Get SFDX auth URLs from each org:

```bash
# For Dev Hub (used by CI pipeline to create scratch orgs)
sf org display --target-org DevHub --verbose | grep "Sfdx Auth Url"

# For Staging Sandbox
sf org display --target-org Staging --verbose | grep "Sfdx Auth Url"

# For Production Org
sf org display --target-org Production --verbose | grep "Sfdx Auth Url"
```

### Step 2: Store as GitHub Secrets

Go to: **Repo Settings → Secrets and variables → Actions**

Add these secrets:
- `DEVHUB_SFDX_URL` — from Dev Hub display command
- `STAGING_SFDX_URL` — from Staging display command
- `PRODUCTION_SFDX_URL` — from Production display command

### Step 3: Configure Branch Protection

Go to: **Repo Settings → Branches → Add rule**

**Branch name pattern:** `main`

✅ **Enable these:**
- Require a pull request before merging
- Require status checks to pass before merging
  - Select: `lwc-tests` AND `validate-apex`
- Require branches to be up to date before merging
- Dismiss stale pull request approvals on new commits

❌ **Disable these:**
- Allow force pushes
- Allow deletions
- Allow bypassing required checks

## 📊 Pipeline Jobs

### Job 1: LWC Jest Tests (~2 minutes)

Runs on every PR:
- Installs Node dependencies
- Runs Jest tests with coverage
- Uploads coverage artifacts

**Fails if:** Tests fail or coverage is insufficient

### Job 2: Apex Validation (~15 minutes)

Runs on every PR after Job 1 passes:
- Creates fresh scratch org
- Deploys all metadata
- Runs all Apex tests with `RunLocalTests`
- Asserts **≥85% code coverage**
- Cleans up scratch org

**Fails if:** Tests fail or coverage < 85%

### Job 3: Deploy to Staging

Triggers **automatically** when PR is merged to `main`:
- Authenticates to Staging sandbox
- Deploys all metadata
- Runs `RunLocalTests`

Requires **manual approval** in GitHub environment

### Job 4: Deploy to Production

Triggers **automatically** after Staging deployment succeeds:
- Authenticates to Production org
- Deploys all metadata
- Runs `RunLocalTests`

Requires **manual approval** in GitHub environment

## 💻 Development Workflow

### Creating a Feature

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes to force-app/
# Develop in scratch org
sf project deploy start --source-dir force-app

# Run tests locally
npm test
sf apex run test --target-org dev --test-level RunLocalTests --code-coverage
```

### Pushing and PR

```bash
git add .
git commit -m "feat: add case search LWC"
git push origin feature/my-feature
```

Go to GitHub, open PR. Pipeline runs automatically:
1. LWC tests run
2. Apex validation on fresh scratch org
3. Both must pass before PR is mergeable

### Merging to Main

After PR approval and all checks pass:
```bash
# Merge on GitHub (or via CLI)
git checkout main && git merge feature/my-feature
```

Pipeline continues:
- Job 3: Auto-deploys to Staging
- Job 4: Waits for manual approval, then deploys to Production

## 🧪 Test Coverage

### Apex Tests

The `CaseAgentActionsTest` class covers:

| Method | Tests |
|--------|-------|
| `getCaseDetails()` | Found, Not Found, Multiple Cases |
| `updateCaseStatus()` | Single update, Bulk updates |
| `checkReturnEligibility()` | Eligible, Not Eligible, Edge Cases, Invalid Date, Multiple Requests |

**Current coverage:** 100% (meets 85% requirement)

### LWC Tests (Jest)

The `caseSearch.test.js` covers:

- Component renders with input field
- Search and Clear buttons present
- Input value updates on change
- Toast error on empty search
- Form clears on Clear button
- Case details display on success
- Error handling and display
- Apex method error handling

**Current coverage:** 85%+

## 🔐 Security Best Practices

✅ **Implemented:**
- Auth URLs stored in GitHub Secrets (never in code)
- `sf org login sfdx-url` uses encrypted auth file
- Test org (`ci-org`) is deleted after each run (no persistent credentials)
- Branch protection prevents direct pushes to `main`
- Manual approval gates on production deployments

## 📝 What to Say in Interviews

### On Deployment Strategy

> "Git is the source of truth for all metadata. Every PR spins up a fresh scratch org, deploys all code, runs the full test suite, and validates 85%+ coverage. Staging deployment is automatic. Production requires manual approval. This gives us confidence in every release."

### On Test Coverage

> "We maintain ≥85% code coverage as a hard requirement in CI. The pipeline asserts this on every PR—code can't be merged if it brings coverage below the threshold. This prevents technical debt."

### On Scratch Orgs

> "Scratch orgs let us create fresh environments for every CI run. They're ephemeral—spun up for testing, deleted immediately after. Zero cost, zero pollution, perfect for validation."

### On Scaling

> "This setup handles teams up to ~20 developers. For larger teams or regulated industries, we'd add Copado for visual conflict resolution and compliance tracking. But for most mid-market companies, SFDX CI/CD is the sweet spot."

## 🛠️ Troubleshooting

### "Dev Hub login expired"
```bash
sf org login web --set-default-dev-hub --alias DevHub
```

### "Scratch org quota exceeded"
Check your Dev Hub's daily scratch org limit. Wait 24 hours or contact Salesforce.

### "Coverage below 85%"
- Check test results: `sf apex run test --target-org dev --code-coverage`
- Add missing test cases to `CaseAgentActionsTest`
- Ensure all methods have test coverage

### "GitHub secret not working"
- Verify secret name matches `.yml` exactly: `${{ secrets.DEVHUB_SFDX_URL }}`
- Re-generate auth URL: `sf org display --target-org DevHub --verbose`
- Update secret in GitHub repo settings

### "Apex deployment fails in CI"
- Check logs in GitHub Actions tab
- Validate locally: `sf project deploy start --source-dir force-app --target-org dev`
- Ensure all metadata files have `-meta.xml` counterparts

## 📚 Resources

- [Salesforce CLI Documentation](https://developer.salesforce.com/tools/sfdxcli)
- [GitHub Actions for Salesforce](https://github.com/marketplace/actions/salesforce-cli-action)
- [Scratch Orgs](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_intro.htm)
- [Apex Testing](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing.htm)
- [Jest Testing Library for LWC](https://github.com/salesforce/lwc/tree/master/packages/@lwc/jest-transformer)

## 📄 License

MIT

---

**Built for:** Technical Certification Portfolio | **Status:** Production-Ready | **Last Updated:** June 2026
