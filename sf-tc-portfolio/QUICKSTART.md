# 🚀 Quick Start Checklist

## Phase 1: Local Development (30 min)

- [ ] Clone project: `git clone https://github.com/YOUR_USERNAME/sf-tc-portfolio.git`
- [ ] Navigate to project: `cd sf-tc-portfolio`
- [ ] Install Node 18+: `node --version` (should be v18+)
- [ ] Install Salesforce CLI: `npm install -g @salesforce/cli`
- [ ] Install npm packages: `npm install`
- [ ] Authenticate Dev Hub: `sf org login web --set-default-dev-hub --alias DevHub`
- [ ] Create scratch org: 
  ```bash
  sf org create scratch \
    --definition-file config/project-scratch-def.json \
    --alias dev --duration-days 30 --set-default
  ```
- [ ] Deploy to scratch org: `sf project deploy start --source-dir force-app`
- [ ] Run tests:
  - [ ] Apex: `sf apex run test --target-org dev --test-level RunLocalTests --code-coverage`
  - [ ] LWC: `npm test`

## Phase 2: GitHub Setup (15 min)

- [ ] Create GitHub repo: https://github.com/new → `sf-tc-portfolio`
- [ ] Push code to GitHub:
  ```bash
  git remote add origin https://github.com/YOUR_USERNAME/sf-tc-portfolio.git
  git branch -M main
  git push -u origin main
  ```
- [ ] Get auth URLs:
  - [ ] Dev Hub: `sf org display --target-org DevHub --verbose` → Copy "Sfdx Auth Url"
  - [ ] (Optional) Staging: `sf org login web --alias Staging` then display auth URL
  - [ ] (Optional) Production: `sf org login web --alias Production` then display auth URL

- [ ] Add GitHub Secrets (Settings → Secrets and variables → Actions):
  - [ ] `DEVHUB_SFDX_URL` = (paste DevHub Sfdx Auth Url)
  - [ ] `STAGING_SFDX_URL` = (paste Staging Sfdx Auth Url or use DevHub URL)
  - [ ] `PRODUCTION_SFDX_URL` = (paste Production Sfdx Auth Url or use DevHub URL)

- [ ] Configure Branch Protection (Settings → Branches → Add rule):
  - [ ] Branch name: `main`
  - [ ] ✅ Require a pull request before merging
  - [ ] ✅ Require status checks: `lwc-tests` AND `validate-apex`
  - [ ] ✅ Require branches to be up to date before merging
  - [ ] ✅ Dismiss stale pull request approvals on new commits
  - [ ] ❌ Disable: Allow force pushes, Allow deletions, Allow bypassing requirements

## Phase 3: Test the Pipeline (10 min)

- [ ] Create feature branch: `git checkout -b feature/test-pipeline`
- [ ] Make a small change (add comment to CaseAgentActions.cls)
- [ ] Commit and push:
  ```bash
  git add force-app/
  git commit -m "test: verify pipeline"
  git push origin feature/test-pipeline
  ```
- [ ] Go to GitHub → Open Pull Request
- [ ] Watch the pipeline run:
  - [ ] LWC tests should pass (~2 min)
  - [ ] Apex validation should pass (~15 min)
  - [ ] Both required for merge ✅
- [ ] Merge PR: Click "Squash and merge"
- [ ] Check Actions tab:
  - [ ] Auto-deploy to Staging should run
  - [ ] Manual approval gate appears for Production
  - [ ] Approve and merge to Production (or skip for now)

## 📚 Documentation to Read

- [ ] **PROJECT_SUMMARY.md** ← Start here for overview
- [ ] **README.md** ← Architecture, interview prep, troubleshooting
- [ ] **SETUP.md** ← Detailed step-by-step walkthrough
- [ ] **.github/workflows/ci.yml** ← The actual pipeline (4 jobs)

## 🧪 Project Components

| Component | File | Purpose | Tests |
|-----------|------|---------|-------|
| CaseAgentActions | `force-app/main/default/classes/CaseAgentActions.cls` | Case mgmt API | 10 test methods |
| Tests | `force-app/main/default/classes/CaseAgentActionsTest.cls` | Apex coverage | 100% coverage |
| LWC | `force-app/main/default/lwc/caseSearch/` | UI component | Jest tests |

## ✅ What You'll Have After This

- ✅ Working Salesforce project in VS Code
- ✅ Scratch org for local development
- ✅ GitHub repo with CI/CD pipeline
- ✅ Automated testing on every PR (Jest + Apex)
- ✅ Automatic staging deployment
- ✅ Manual approval gate for production
- ✅ 100% Apex code coverage (exceeds 85% requirement)
- ✅ Portfolio piece for interviews

## 🎤 Interview-Ready Talking Points

When asked about deployment strategy:

> "We use Git as the source of truth. Every PR runs a fresh scratch org with full test coverage gates. Both Jest and Apex tests must pass. After merge to main, we auto-deploy to staging. Production requires manual approval. Zero surprises, full traceability."

## 🆘 If Something Goes Wrong

| Issue | Solution |
|-------|----------|
| Scratch org expired | `sf org delete scratch --target-org dev --no-prompt` then recreate |
| Dev Hub auth expired | `sf org login web --set-default-dev-hub --alias DevHub` |
| GitHub Actions failing | Check `.github/workflows/ci.yml` → run `sf project deploy start --source-dir force-app --target-org dev` locally first |
| Coverage below 85% | Run `sf apex run test --target-org dev --code-coverage` → add missing test cases |
| Secret not working | Regenerate auth URL and update GitHub secret |

## 📞 Resources

- [Salesforce SFDX Docs](https://developer.salesforce.com/tools/sfdxcli)
- [GitHub Actions](https://github.com/marketplace/actions/salesforce-cli-action)
- [Scratch Orgs](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_intro.htm)
- [Apex Testing](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing.htm)
- [LWC Jest Tests](https://github.com/salesforce/lwc/tree/master/packages/@lwc/jest-transformer)

---

**Ready?** Follow the steps above, top to bottom. You've got ~1 hour total.

**Stuck?** Check **README.md** → Troubleshooting section or read **SETUP.md** for detailed walkthrough.

**Questions before you start?** Re-read this checklist. Everything's here. 🚀
