/**
 * CaseAgentActionsTest
 * Complete test coverage for CaseAgentActions
 * Tests: getCaseDetails, updateCaseStatus, checkReturnEligibility
 */
@isTest
public class CaseAgentActionsTest {

    @TestSetup
    static void makeData() {
        Account acc = new Account(Name = 'Test Corp');
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test@test.com',
            AccountId = acc.Id
        );
        insert con;
        
        insert new Case(
            Subject = 'Billing Issue',
            Status = 'New',
            ContactId = con.Id,
            AccountId = acc.Id
        );
        
        insert new Case(
            Subject = 'Return Request',
            Status = 'New',
            ContactId = con.Id,
            AccountId = acc.Id
        );
    }

    @isTest
    static void testGetCase_found() {
        Case c = [SELECT CaseNumber FROM Case WHERE Subject = 'Billing Issue' LIMIT 1];
        
        Test.startTest();
        List<CaseAgentActions.CaseDetail> results = CaseAgentActions.getCaseDetails(
            new List<String>{ c.CaseNumber }
        );
        Test.stopTest();
        
        System.assertEquals(true, results[0].found, 'Should be found');
        System.assertEquals(c.CaseNumber, results[0].caseNumber, 'Wrong case number');
        System.assertEquals('Billing Issue', results[0].subject, 'Wrong subject');
    }

    @isTest
    static void testGetCase_notFound() {
        Test.startTest();
        List<CaseAgentActions.CaseDetail> results = CaseAgentActions.getCaseDetails(
            new List<String>{ '99999999' }
        );
        Test.stopTest();
        
        System.assertEquals(false, results[0].found, 'Should not be found');
        System.assertEquals('99999999', results[0].caseNumber, 'Case number mismatch');
    }

    @isTest
    static void testGetCase_multipleCases() {
        List<Case> cases = [SELECT CaseNumber FROM Case ORDER BY CreatedDate LIMIT 2];
        List<String> caseNumbers = new List<String>();
        for (Case c : cases) {
            caseNumbers.add(c.CaseNumber);
        }
        
        Test.startTest();
        List<CaseAgentActions.CaseDetail> results = CaseAgentActions.getCaseDetails(caseNumbers);
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should return 2 results');
        System.assertEquals(true, results[0].found, 'First case should be found');
        System.assertEquals(true, results[1].found, 'Second case should be found');
    }

    @isTest
    static void testUpdateCaseStatus() {
        Case c = [SELECT Id FROM Case WHERE Subject = 'Billing Issue' LIMIT 1];
        
        CaseAgentActions.CaseUpdateRequest req = new CaseAgentActions.CaseUpdateRequest();
        req.caseId = c.Id;
        req.newStatus = 'Working';
        
        Test.startTest();
        List<String> results = CaseAgentActions.updateCaseStatus(
            new List<CaseAgentActions.CaseUpdateRequest>{ req }
        );
        Test.stopTest();
        
        System.assertEquals('Success', results[0], 'Update should succeed');
        
        Case updatedCase = [SELECT Status FROM Case WHERE Id = :c.Id];
        System.assertEquals('Working', updatedCase.Status, 'Status should be updated');
    }

    @isTest
    static void testUpdateCaseStatus_multiple() {
        List<Case> cases = [SELECT Id FROM Case ORDER BY CreatedDate LIMIT 2];
        
        List<CaseAgentActions.CaseUpdateRequest> requests = new List<CaseAgentActions.CaseUpdateRequest>();
        for (Case c : cases) {
            CaseAgentActions.CaseUpdateRequest req = new CaseAgentActions.CaseUpdateRequest();
            req.caseId = c.Id;
            req.newStatus = 'Closed';
            requests.add(req);
        }
        
        Test.startTest();
        List<String> results = CaseAgentActions.updateCaseStatus(requests);
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should update 2 cases');
        for (String result : results) {
            System.assertEquals('Success', result, 'Both should succeed');
        }
    }

    @isTest
    static void testReturn_eligible() {
        CaseAgentActions.ReturnRequest req = new CaseAgentActions.ReturnRequest();
        req.orderDateStr = Date.today().addDays(-10).format();
        
        Test.startTest();
        List<CaseAgentActions.ReturnEligibility> r = CaseAgentActions.checkReturnEligibility(
            new List<CaseAgentActions.ReturnRequest>{ req }
        );
        Test.stopTest();
        
        System.assertEquals(true, r[0].eligible, 'Should be eligible');
        System.assertEquals(20, r[0].daysRemaining, 'Should have 20 days remaining');
    }

    @isTest
    static void testReturn_notEligible() {
        CaseAgentActions.ReturnRequest req = new CaseAgentActions.ReturnRequest();
        req.orderDateStr = Date.today().addDays(-45).format();
        
        Test.startTest();
        List<CaseAgentActions.ReturnEligibility> r = CaseAgentActions.checkReturnEligibility(
            new List<CaseAgentActions.ReturnRequest>{ req }
        );
        Test.stopTest();
        
        System.assertEquals(false, r[0].eligible, 'Should not be eligible');
        System.assertEquals(0, r[0].daysRemaining, 'Should have 0 days remaining');
    }

    @isTest
    static void testReturn_edgeCase_lastDay() {
        CaseAgentActions.ReturnRequest req = new CaseAgentActions.ReturnRequest();
        req.orderDateStr = Date.today().addDays(-30).format();
        
        Test.startTest();
        List<CaseAgentActions.ReturnEligibility> r = CaseAgentActions.checkReturnEligibility(
            new List<CaseAgentActions.ReturnRequest>{ req }
        );
        Test.stopTest();
        
        System.assertEquals(true, r[0].eligible, 'Should be eligible on last day');
        System.assertEquals(0, r[0].daysRemaining, 'Should have 0 days remaining');
    }

    @isTest
    static void testReturn_multipleRequests() {
        List<CaseAgentActions.ReturnRequest> requests = new List<CaseAgentActions.ReturnRequest>();
        
        CaseAgentActions.ReturnRequest req1 = new CaseAgentActions.ReturnRequest();
        req1.orderDateStr = Date.today().addDays(-10).format();
        requests.add(req1);
        
        CaseAgentActions.ReturnRequest req2 = new CaseAgentActions.ReturnRequest();
        req2.orderDateStr = Date.today().addDays(-35).format();
        requests.add(req2);
        
        Test.startTest();
        List<CaseAgentActions.ReturnEligibility> results = CaseAgentActions.checkReturnEligibility(requests);
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should return 2 results');
        System.assertEquals(true, results[0].eligible, 'First should be eligible');
        System.assertEquals(false, results[1].eligible, 'Second should not be eligible');
    }

    @isTest
    static void testReturn_invalidDate() {
        CaseAgentActions.ReturnRequest req = new CaseAgentActions.ReturnRequest();
        req.orderDateStr = 'invalid-date';
        
        Test.startTest();
        List<CaseAgentActions.ReturnEligibility> r = CaseAgentActions.checkReturnEligibility(
            new List<CaseAgentActions.ReturnRequest>{ req }
        );
        Test.stopTest();
        
        System.assertEquals(false, r[0].eligible, 'Should not be eligible');
        System.assertNotEquals(null, r[0].errorMessage, 'Should have error message');
    }

    @isTest
    static void testEmptyRequests() {
        Test.startTest();
        List<CaseAgentActions.CaseDetail> detailResults = CaseAgentActions.getCaseDetails(new List<String>());
        List<String> updateResults = CaseAgentActions.updateCaseStatus(new List<CaseAgentActions.CaseUpdateRequest>());
        List<CaseAgentActions.ReturnEligibility> returnResults = CaseAgentActions.checkReturnEligibility(new List<CaseAgentActions.ReturnRequest>());
        Test.stopTest();
        
        System.assertEquals(0, detailResults.size(), 'Should return empty list for details');
        System.assertEquals(0, updateResults.size(), 'Should return empty list for updates');
        System.assertEquals(0, returnResults.size(), 'Should return empty list for returns');
    }
}
