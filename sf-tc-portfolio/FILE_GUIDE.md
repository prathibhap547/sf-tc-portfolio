# 📂 Complete File Directory & Guide

## Project Structure at a Glance

```
sf-tc-portfolio/
├── 📋 Documentation (READ THESE FIRST)
│   ├── PROJECT_SUMMARY.md          ← Overview of entire project
│   ├── README.md                   ← Full guide + interview prep
│   ├── SETUP.md                    ← Step-by-step setup (30 min)
│   ├── QUICKSTART.md               ← Quick checklist
│   └── FILE_GUIDE.md               ← This file
│
├── ⚙️ Configuration Files (Project Setup)
│   ├── package.json                ← npm dependencies (Jest, SFDX)
│   ├── sfdx-project.json          ← SFDX project metadata
│   ├── .gitignore                 ← What Git ignores
│   └── .eslintrc.json             ← Code quality standards
│
├── 🧪 Jest Configuration (Testing)
│   ├── jest.setup.js              ← Jest test setup
│   └── jest.mocks.js              ← Mock Lightning imports
│
├── 🔄 GitHub Actions Pipeline
│   └── .github/
│       └── workflows/
│           └── ci.yml             ← 4-job CI/CD pipeline
│
├── ⚙️ Salesforce Configuration
│   └── config/
│       └── project-scratch-def.json ← Scratch org definition
│
└── 💪 Salesforce Metadata
    └── force-app/
        └── main/
            └── default/
                ├── classes/                    (Apex code)
                │   ├── CaseAgentActions.cls
                │   ├── CaseAgentActions.cls-meta.xml
                │   ├── CaseAgentActionsTest.cls
                │   └── CaseAgentActionsTest.cls-meta.xml
                │
                └── lwc/                        (Lightning Web Components)
                    └── caseSearch/
                        ├── caseSearch.html
                        ├── caseSearch.js
                        ├── caseSearch.js-meta.xml
                        └── __tests__/
                            └── caseSearch.test.js
```

---

## 📄 File-by-File Breakdown

### 📋 Documentation Files

#### **PROJECT_SUMMARY.md** (Start here!)
- **What it is:** 2-page overview of the entire project
- **Who reads it:** You, before starting anything else
- **Contains:** Project structure, components explained, interview talking points
- **Time to read:** 10 minutes

#### **README.md** (The complete guide)
- **What it is:** 50-page enterprise documentation
- **Who reads it:** Developers implementing this, interviewers reviewing your work
- **Contains:** Architecture, setup, pipeline explanation, troubleshooting, interview Q&A
- **Key sections:** 
  - Pipeline flow diagram
  - Step-by-step setup
  - Test coverage details
  - Interview talking points (IMPORTANT)
  - Troubleshooting guide
- **Time to read:** 30 minutes (but worth it)

#### **SETUP.md** (Do this next)
- **What it is:** Hands-on walkthrough in 4 phases
- **Who reads it:** You during setup
- **Contains:** Phase 1 (local dev), Phase 2 (GitHub), Phase 3 (test pipeline), Phase 4 (ongoing)
- **Key sections:**
  - Local development setup (Part 1)
  - GitHub configuration (Part 2)
  - Testing the pipeline (Part 3)
  - Daily development workflow (Part 4)
  - Troubleshooting Q&A
- **Time to follow:** 1 hour total

#### **QUICKSTART.md** (Your checklist)
- **What it is:** TL;DR checklist version of SETUP
- **Who reads it:** You want the fastest path to "working"
- **Contains:** Checkboxes for each step
- **Key sections:**
  - Phase 1 (30 min)
  - Phase 2 (15 min)
  - Phase 3 (10 min)
  - Resource links
- **Time to follow:** 1 hour, quick reference

#### **FILE_GUIDE.md** (This file)
- **What it is:** Directory of every file and what it does
- **Who reads it:** You need to understand what each file is for

---

### ⚙️ Configuration Files (Root Directory)

#### **package.json**
- **Purpose:** npm dependencies and project metadata
- **Key dependencies:**
  ```json
  {
    "devDependencies": {
      "jest": "^29.7.0",              // JavaScript testing
      "@salesforce/cli": "^2.41.0",  // Salesforce CLI
      "eslint": "^8.57.0"            // Code quality
    }
  }
  ```
- **npm scripts:**
  ```bash
  npm test              # Run Jest tests
  npm run lint          # Check code quality
  ```
- **Edit it if:** You need to add new npm packages

#### **sfdx-project.json**
- **Purpose:** Salesforce SFDX project metadata
- **Key config:**
  ```json
  {
    "sourceApiVersion": "59.0",    // Salesforce API version
    "packageDirectories": [
      { "path": "force-app", "default": true }
    ]
  }
  ```
- **Edit it if:** You change the API version or project structure

#### **.gitignore**
- **Purpose:** Tells Git what files NOT to commit
- **Important patterns:**
  ```
  node_modules/        # Don't commit npm packages
  .sfdx/              # Don't commit Salesforce auth
  *.json.bak          # Don't commit backup files
  devhub.json         # Never commit auth files!
  ```
- **Edit it if:** You add new file types to ignore

#### **.eslintrc.json**
- **Purpose:** Code quality standards for Lightning Web Components
- **Enforces:**
  - No `var` (use `let`/`const`)
  - Consistent code style
  - Salesforce LWC best practices
- **Edit it if:** You want stricter or looser linting rules

---

### 🧪 Jest Testing Configuration

#### **jest.setup.js**
- **Purpose:** Jest test environment configuration
- **What it does:** Minimal setup (mostly empty, Jest handles defaults)
- **Edit it if:** You need custom test environment setup

#### **jest.mocks.js**
- **Purpose:** Mock Lightning Web Component imports for testing
- **Mocks:**
  ```javascript
  'lightning/navigation'           // Navigation service
  'lightning/platformShowToastEvent'  // Toast notifications
  'lightning/uiRecordApi'          // Record API calls
  ```
- **Why needed:** LWC components import from `lightning/*` which don't exist in Node.js
- **Edit it if:** You add new LWC imports that need mocking

---

### 🔄 GitHub Actions Pipeline

#### **.github/workflows/ci.yml** (THE MOST IMPORTANT FILE!)
- **Purpose:** Defines the entire CI/CD pipeline
- **4 Jobs:**
  1. **lwc-tests** (~2 min)
     - Runs: `npm test`
     - On: Every PR to main or feature branches
     - Must pass before PR can merge
  
  2. **validate-apex** (~15 min)
     - Creates fresh scratch org
     - Deploys all metadata
     - Runs all Apex tests
     - Asserts ≥85% coverage
     - Deletes scratch org
     - On: Every PR, requires lwc-tests to pass
     - Must pass before PR can merge
  
  3. **deploy-staging** (Auto)
     - On: Merge to main only
     - Deploys to Staging sandbox
     - Requires manual approval
  
  4. **deploy-production** (Manual)
     - On: After staging deployment
     - Deploys to Production
     - Requires manual approval
- **Edit it if:** You want to change job behavior, add/remove jobs, change coverage threshold, etc.

---

### ⚙️ Salesforce Configuration

#### **config/project-scratch-def.json**
- **Purpose:** Defines what's in a scratch org
- **Key settings:**
  ```json
  {
    "orgName": "TC Portfolio Dev",
    "edition": "Developer",
    "features": ["Communities", "Knowledge"],
    "settings": {
      "lightningExperienceSettings": {
        "enableS1DesktopEnabled": true
      }
    }
  }
  ```
- **What it controls:**
  - Org name
  - Edition (Developer, Enterprise, etc.)
  - Enabled features (Communities, Knowledge, etc.)
  - Custom settings (Lightning, Apex, Case settings)
- **Edit it if:** You need to enable different features (e.g., Financial Services, CPQ)

---

### 💪 Apex Classes (Business Logic)

#### **force-app/main/default/classes/CaseAgentActions.cls**
- **Type:** Main business logic class
- **Purpose:** Case management API
- **Methods:**
  ```apex
  getCaseDetails(List<String> caseNumbers)
    → Returns: found status, case details
  
  updateCaseStatus(List<CaseUpdateRequest> requests)
    → Returns: success/error messages
  
  checkReturnEligibility(List<ReturnRequest> requests)
    → Returns: eligible flag, days remaining
  ```
- **Inner classes:**
  - `CaseDetail` (response wrapper)
  - `CaseUpdateRequest` (request wrapper)
  - `ReturnRequest` (request wrapper)
  - `ReturnEligibility` (response wrapper)
- **Code coverage:** 100% (all lines tested)
- **Edit it if:** You want to add case management features

#### **force-app/main/default/classes/CaseAgentActions.cls-meta.xml**
- **Purpose:** Metadata declaration for CaseAgentActions class
- **Contains:**
  ```xml
  <apiVersion>59.0</apiVersion>
  <status>Active</status>
  ```
- **Edit it if:** You change the API version

#### **force-app/main/default/classes/CaseAgentActionsTest.cls**
- **Type:** Apex test class
- **Purpose:** Test coverage for CaseAgentActions
- **Test methods (10 total):**
  ```apex
  testGetCase_found()               // Case lookup success
  testGetCase_notFound()            // Case lookup failure
  testGetCase_multipleCases()       // Bulk case lookup
  testUpdateCaseStatus()            // Single status update
  testUpdateCaseStatus_multiple()   // Bulk status updates
  testReturn_eligible()             // Return eligibility (within 30 days)
  testReturn_notEligible()          // Return eligibility (after 30 days)
  testReturn_edgeCase_lastDay()     // Return on last day of window
  testReturn_multipleRequests()     // Bulk return checks
  testReturn_invalidDate()          // Error handling
  testEmptyRequests()               // Empty list handling
  ```
- **Coverage:** 100% of CaseAgentActions.cls
- **Edit it if:** You add new methods to CaseAgentActions

#### **force-app/main/default/classes/CaseAgentActionsTest.cls-meta.xml**
- **Purpose:** Metadata declaration for test class
- **Edit it if:** You change API version

---

### 💻 Lightning Web Components

#### **force-app/main/default/lwc/caseSearch/caseSearch.js**
- **Type:** LWC component logic
- **Purpose:** Search for cases by case number
- **Methods:**
  ```javascript
  handleInputChange()    // Update case number input
  handleSearch()         // Search for case
  handleClear()          // Clear form
  showToast()            // Show notification
  ```
- **Features:**
  - Searches cases by number
  - Shows case details (subject, status)
  - Error handling
  - Loading state
- **Edit it if:** You want to change search behavior or add features

#### **force-app/main/default/lwc/caseSearch/caseSearch.html**
- **Type:** LWC component template
- **Purpose:** HTML markup for case search component
- **Contains:**
  - Input field for case number
  - Search and Clear buttons
  - Results display
  - Error messages
  - Loading spinner
- **Edit it if:** You want to change the UI

#### **force-app/main/default/lwc/caseSearch/caseSearch.js-meta.xml**
- **Purpose:** LWC metadata configuration
- **Contains:**
  ```xml
  <apiVersion>59.0</apiVersion>
  <isExposed>true</isExposed>
  <targets>
    <target>lightning__RecordPage</target>  <!-- Can be used on record pages -->
    <target>lightning__AppPage</target>     <!-- Can be used on app pages -->
    <target>lightning__HomePage</target>    <!-- Can be used on home page -->
  </targets>
  ```
- **Edit it if:** You want to change where the component can be used

#### **force-app/main/default/lwc/caseSearch/__tests__/caseSearch.test.js**
- **Type:** Jest test file for LWC component
- **Purpose:** Test caseSearch component behavior
- **Tests (8 scenarios):**
  ```javascript
  renders component with input field
  renders search and clear buttons
  updates caseNumber on input change
  shows toast error when searching with empty case number
  clears form on clear button click
  displays case details when search succeeds
  shows error when case not found
  handles Apex method error gracefully
  ```
- **Coverage:** 85%+
- **Edit it if:** You add new features to caseSearch component

---

## 🔍 How Files Work Together

### Example: Testing & Deployment Flow

```
Developer makes a change
    ↓
Edits: force-app/main/default/classes/CaseAgentActions.cls
    ↓
Runs locally: sf apex run test --target-org dev
Uses: CaseAgentActionsTest.cls (to verify 100% coverage)
    ↓
Commits and pushes
    ↓
GitHub Actions reads: .github/workflows/ci.yml
    ↓
Job 1 runs: npm test
Uses: package.json, jest.setup.js, jest.mocks.js
Tests: caseSearch.test.js
    ↓
Job 2 runs: Apex validation
Uses: config/project-scratch-def.json (creates fresh org)
Deploys: All files in force-app/
Tests: CaseAgentActionsTest.cls (asserts ≥85% coverage)
    ↓
If all pass: PR can merge to main
    ↓
Job 3 runs: Deploy to Staging
Uses: sfdx-project.json, package.json
Deploys to Staging sandbox
    ↓
Manual approval → Job 4 runs: Deploy to Production
```

---

## 📊 File Statistics

| Category | Count | Total Size |
|----------|-------|------------|
| Documentation | 4 | ~40 KB |
| Config | 4 | ~5 KB |
| Apex Classes | 2 | ~12 KB |
| Apex Tests | 1 | ~8 KB |
| LWC Components | 1 | ~4 KB |
| LWC Tests | 1 | ~5 KB |
| GitHub Actions | 1 | ~4 KB |
| **TOTAL** | **14** | **~78 KB** |

---

## 🎯 Files You'll Edit Most

1. **force-app/main/default/classes/CaseAgentActions.cls** — Add business logic
2. **force-app/main/default/classes/CaseAgentActionsTest.cls** — Add test cases
3. **force-app/main/default/lwc/caseSearch/caseSearch.js** — Add LWC features
4. **force-app/main/default/lwc/caseSearch/caseSearch.html** — Update UI
5. **.github/workflows/ci.yml** — Adjust pipeline (rarely)

---

## 🚀 Quick File Reference

Need to...

- **Add a new Apex class?** → Create in `force-app/main/default/classes/`
- **Add LWC tests?** → Add to `force-app/main/default/lwc/ComponentName/__tests__/`
- **Change coverage threshold?** → Edit `.github/workflows/ci.yml` (search for "85%")
- **Add new npm package?** → Edit `package.json` (run `npm install`)
- **Add new LWC features?** → Edit `caseSearch.js` and `caseSearch.html`
- **Enable new Salesforce feature?** → Edit `config/project-scratch-def.json`
- **Change code quality rules?** → Edit `.eslintrc.json`

---

## ✅ Next Steps

1. Read **PROJECT_SUMMARY.md** (10 min)
2. Follow **SETUP.md** or **QUICKSTART.md** (1 hour)
3. Get comfortable with the files
4. Make changes to `CaseAgentActions.cls` or `caseSearch.js`
5. Run tests: `npm test` and `sf apex run test --target-org dev`
6. Commit and push
7. Watch GitHub Actions run

---

**Any questions about a specific file?** Search the file name in this document or check **README.md** → Troubleshooting.
