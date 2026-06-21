# Step-by-Step Setup Guide

## Part 1: Local Development Setup (30 minutes)

### 1.1 Install Prerequisites

```bash
# Install Node.js 18+ (if not already installed)
node --version  # Should be v18.0.0 or higher

# Install Salesforce CLI globally
npm install -g @salesforce/cli

# Verify installation
sf version
```

### 1.2 Clone Repository

```bash
git clone https://github.com/prathibhap547/sf-tc-portfolio.git
cd sf-tc-portfolio
```

### 1.3 Install NPM Dependencies

```bash
npm install
# or
yarn install
```

### 1.4 Authorize Dev Hub

Your Salesforce Developer Edition will be used as the Dev Hub (creates scratch orgs):

```bash
sf org login web --set-default-dev-hub --alias DevHub
```

This opens a browser window:
1. Log in with your Salesforce Developer Edition credentials
2. Grant access to Salesforce CLI
3. Return to terminal—connection saved as `DevHub`

Verify:
```bash
sf org list --all
# You should see DevHub listed
```

### 1.5 Create Scratch Org for Development

```bash
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias dev \
  --duration-days 30 \
  --set-default

# Open in browser
sf org open
```

Wait a few seconds for org to initialize, then browser opens to your scratch org.

### 1.6 Deploy Metadata to Scratch Org

```bash
sf project deploy start --source-dir force-app
```

Expected output:
```
Deploying to org with ID: 00D... (dev)
Deploy ID: 0Af...
  ✓ CaseAgentActions
  ✓ CaseAgentActionsTest
  ✓ caseSearch
Status: Done
```

### 1.7 Run Tests Locally

**Apex tests:**
```bash
sf apex run test \
  --target-org dev \
  --test-level RunLocalTests \
  --code-coverage
```

Should pass with 100% coverage.

**LWC Jest tests:**
```bash
npm test
```

Press `q` to exit test watch mode.

---

## Part 2: GitHub Configuration (15 minutes)

### 2.1 Create GitHub Repository

1. Go to https://github.com/new
2. Create public repo named `sf-tc-portfolio`
3. Do NOT initialize with README (we have one)

### 2.2 Push Code to GitHub

```bash
git remote add origin https://github.com/prathibhap547/sf-tc-portfolio.git
git branch -M main
git push -u origin main
```

### 2.3 Generate Auth URLs for CI

You need to get SFDX Auth URLs from your orgs (for GitHub Secrets):

**Dev Hub:**
```bash
sf org display --target-org DevHub --verbose
```

Find the line that says `Sfdx Auth Url` and copy it.

**Staging Sandbox** (if you have one):
```bash
# First, log in to your staging sandbox
sf org login web --alias Staging

# Then display the auth URL
sf org display --target-org Staging --verbose
```

**Production Org** (if you have one):
```bash
# First, log in to your production org
sf org login web --alias Production

# Then display the auth URL
sf org display --target-org Production --verbose
```

### 2.4 Add GitHub Secrets

On GitHub repo:
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**

Add three secrets:

| Secret Name | Value |
|-------------|-------|
| `DEVHUB_SFDX_URL` | Paste DevHub Sfdx Auth Url |
| `STAGING_SFDX_URL` | Paste Staging Sfdx Auth Url (or DevHub URL for testing) |
| `PRODUCTION_SFDX_URL` | Paste Production Sfdx Auth Url (or DevHub URL for testing) |

⚠️ **Important:** Do NOT paste auth URLs anywhere else. GitHub encrypts them.

### 2.5 Configure Branch Protection

1. Go to **Settings** → **Branches**
2. Click **Add branch protection rule**
3. Branch name pattern: `main`
4. Check these boxes:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Dismiss stale pull request approvals on new commits
5. Click **Create**

Now the `main` branch is protected. Force pushes are blocked. All PRs must pass CI checks.

---

## Part 3: Test the Pipeline (10 minutes)

### 3.1 Create a Feature Branch

```bash
git checkout -b feature/test-pipeline
```

### 3.2 Make a Small Change

Edit `force-app/main/default/classes/CaseAgentActions.cls` — add a comment:

```apex
/**
 * CaseAgentActions
 * Apex actions for AI Agent to retrieve and update case information
 * Updated to test CI/CD pipeline
 * Supports: getCaseDetails, updateCaseStatus, checkReturnEligibility
 */
```

### 3.3 Commit and Push

```bash
git add force-app/
git commit -m "chore: test pipeline"
git push origin feature/test-pipeline
```

### 3.4 Create Pull Request

1. Go to your GitHub repo
2. Click **Compare & pull request**
3. Add a title and description
4. Click **Create pull request**

GitHub automatically runs the pipeline:
- **Checking runs** tab appears
- LWC tests run first (~2 min)
- Apex validation runs (~15 min)
- Both must pass

### 3.5 Merge When Green

When all checks are green ✅:
1. Click **Squash and merge** (or your preferred strategy)
2. Confirm merge
3. Delete branch (GitHub offers this)

Pipeline continues:
- Auto-deploys to Staging (because `main` was updated)
- Creates approval gate for Production deployment

---

## Part 4: Working with the Project

### Daily Development

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes in scratch org
sf project deploy start --source-dir force-app

# Run tests
npm test
sf apex run test --target-org dev --test-level RunLocalTests --code-coverage

# Commit and push
git add .
git commit -m "feat: your change"
git push origin feature/my-feature
```

### Updating Scratch Org

When you pull new changes from `main`:

```bash
git checkout main
git pull

# Reset scratch org if needed
sf org delete scratch --target-org dev --no-prompt
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias dev
sf project deploy start --source-dir force-app
```

### Viewing Test Results

On GitHub:
1. Go to **Actions** tab
2. Click on a workflow run
3. Click on job name (e.g., "Apex Tests + Coverage")
4. Scroll to see test output and coverage %

---

## Troubleshooting

### Q: "ECONNREFUSED" when running tests
**A:** Scratch org may have expired. Create a new one:
```bash
sf org delete scratch --target-org dev --no-prompt
sf org create scratch --definition-file config/project-scratch-def.json --alias dev
```

### Q: "Dev Hub login expired"
**A:** Re-authenticate:
```bash
sf org login web --set-default-dev-hub --alias DevHub
```

### Q: GitHub Actions "Unknown error authenticating with DevHub"
**A:** 
1. Regenerate auth URL: `sf org display --target-org DevHub --verbose`
2. Update `DEVHUB_SFDX_URL` secret in GitHub
3. Re-run the workflow

### Q: "Coverage below 85%"
**A:** Add test cases. Run locally and check coverage:
```bash
sf apex run test --target-org dev --code-coverage
```

Add tests to `CaseAgentActionsTest` to cover gaps.

### Q: "Metadata failed to deploy"
**A:** 
1. Check the error in GitHub Actions logs
2. Validate locally: `sf project deploy start --source-dir force-app --target-org dev --test-level RunLocalTests`
3. Fix issues and re-push

---

## Next Steps

Once you're comfortable with this setup:

1. **Add more Apex classes** — Create business logic classes and test them
2. **Add more LWC components** — Build UI components with Jest tests
3. **Add more test orgs** — Deploy to real Staging and Production orgs
4. **Set up Copado** (optional) — For teams >10 or regulated industries

---

**Questions?** Check the main [README.md](./README.md) or Salesforce docs.
