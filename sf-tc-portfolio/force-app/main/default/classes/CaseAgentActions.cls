/**
 * CaseAgentActions
 * Apex actions for AI Agent to retrieve and update case information
 * Supports: getCaseDetails, updateCaseStatus, checkReturnEligibility
 */
public with sharing class CaseAgentActions {

    /**
     * Get detailed information about a case by case number
     * @param caseNumbers List of case numbers to look up
     * @return List of CaseDetail objects with found status and category
     */
    @AuraEnabled
    public static List<CaseDetail> getCaseDetails(List<String> caseNumbers) {
        List<CaseDetail> results = new List<CaseDetail>();
        
        if (caseNumbers == null || caseNumbers.isEmpty()) {
            return results;
        }

        // Query cases by case number
        Map<String, Case> caseMap = new Map<String, Case>();
        for (Case c : [
            SELECT Id, CaseNumber, Subject, Status, ContactId, AccountId
            FROM Case
            WHERE CaseNumber IN :caseNumbers
        ]) {
            caseMap.put(c.CaseNumber, c);
        }

        // Build result for each requested case number
        for (String caseNum : caseNumbers) {
            CaseDetail detail = new CaseDetail();
            if (caseMap.containsKey(caseNum)) {
                Case c = caseMap.get(caseNum);
                detail.found = true;
                detail.caseId = c.Id;
                detail.caseNumber = c.CaseNumber;
                detail.subject = c.Subject;
                detail.status = c.Status;
            } else {
                detail.found = false;
                detail.caseNumber = caseNum;
            }
            results.add(detail);
        }

        return results;
    }

    /**
     * Update case status
     * @param requests List of case update requests with caseId and newStatus
     * @return List of status messages ('Success' or error description)
     */
    @AuraEnabled
    public static List<String> updateCaseStatus(List<CaseUpdateRequest> requests) {
        List<String> results = new List<String>();
        
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        List<Case> casesToUpdate = new List<Case>();
        for (CaseUpdateRequest req : requests) {
            if (req.caseId != null && req.newStatus != null) {
                casesToUpdate.add(new Case(
                    Id = req.caseId,
                    Status = req.newStatus
                ));
            }
        }

        try {
            update casesToUpdate;
            for (Integer i = 0; i < requests.size(); i++) {
                results.add('Success');
            }
        } catch (DmlException e) {
            for (Integer i = 0; i < requests.size(); i++) {
                results.add('Error: ' + e.getMessage());
            }
        }

        return results;
    }

    /**
     * Check if a return is eligible based on order date
     * Returns are eligible within 30 days of the order date
     * @param requests List of return eligibility requests with orderDateStr
     * @return List of return eligibility results with eligible flag and daysRemaining
     */
    @AuraEnabled
    public static List<ReturnEligibility> checkReturnEligibility(List<ReturnRequest> requests) {
        List<ReturnEligibility> results = new List<ReturnEligibility>();
        Integer returnWindowDays = 30;

        if (requests == null || requests.isEmpty()) {
            return results;
        }

        for (ReturnRequest req : requests) {
            ReturnEligibility eligibility = new ReturnEligibility();
            
            try {
                Date orderDate = Date.parse(req.orderDateStr);
                Date today = Date.today();
                Integer daysSinceOrder = orderDate.daysBetween(today);
                
                if (daysSinceOrder <= returnWindowDays) {
                    eligibility.eligible = true;
                    eligibility.daysRemaining = returnWindowDays - daysSinceOrder;
                } else {
                    eligibility.eligible = false;
                    eligibility.daysRemaining = 0;
                }
                eligibility.orderDate = req.orderDateStr;
            } catch (Exception e) {
                eligibility.eligible = false;
                eligibility.daysRemaining = 0;
                eligibility.errorMessage = 'Invalid date format';
            }

            results.add(eligibility);
        }

        return results;
    }

    // ───────── Inner Classes ─────────

    /**
     * Request class for case updates
     */
    public class CaseUpdateRequest {
        @AuraEnabled public String caseId { get; set; }
        @AuraEnabled public String newStatus { get; set; }
    }

    /**
     * Request class for return eligibility checks
     */
    public class ReturnRequest {
        @AuraEnabled public String orderDateStr { get; set; }
    }

    /**
     * Response class for case details
     */
    public class CaseDetail {
        @AuraEnabled public Boolean found { get; set; }
        @AuraEnabled public String caseId { get; set; }
        @AuraEnabled public String caseNumber { get; set; }
        @AuraEnabled public String subject { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String category { get; set; }
    }

    /**
     * Response class for return eligibility
     */
    public class ReturnEligibility {
        @AuraEnabled public Boolean eligible { get; set; }
        @AuraEnabled public Integer daysRemaining { get; set; }
        @AuraEnabled public String orderDate { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
    }
}
