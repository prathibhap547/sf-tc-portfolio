import { createElement } from 'lwc';
import CaseSearch from 'c/caseSearch';
import getCaseDetails from '@salesforce/apex/CaseAgentActions.getCaseDetails';

// Mock the Apex method
jest.mock('@salesforce/apex/CaseAgentActions.getCaseDetails', () => ({
    default: jest.fn()
}));

describe('c-case-search', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    test('renders component with input field', () => {
        const element = createElement('c-case-search', {
            is: CaseSearch
        });
        document.body.appendChild(element);

        const input = element.shadowRoot.querySelector('lightning-input');
        expect(input).toBeTruthy();
    });

    test('renders search and clear buttons', () => {
        const element = createElement('c-case-search', {
            is: CaseSearch
        });
        document.body.appendChild(element);

        const buttons = element.shadowRoot.querySelectorAll('lightning-button');
        expect(buttons.length).toBe(2);
        expect(buttons[0].label).toBe('Search');
        expect(buttons[1].label).toBe('Clear');
    });

    test('updates caseNumber on input change', () => {
        const element = createElement('c-case-search', {
            is: CaseSearch
        });
        document.body.appendChild(element);

        const input = element.shadowRoot.querySelector('lightning-input');
        input.value = '12345';
        input.dispatchEvent(new CustomEvent('change'));

        expect(element.caseNumber).toBe('12345');
    });

    test('shows toast error when searching with empty case number', async () => {
        const element = createElement('c-case-search', {
            is: CaseSearch
        });
        document.body.appendChild(element);

        const dispatchEventSpy = jest.spyOn(element, 'dispatchEvent');
        
        // Manually set empty case number and call search
        element.caseNumber = '';
        const button = element.shadowRoot.querySelectorAll('lightning-button')[0];
        button.click();

        await new Promise(resolve => setTimeout(resolve, 0));

        expect(dispatchEventSpy).toHaveBeenCalled();
    });

    test('clears form on clear button click', async () => {
        const element = createElement('c-case-search', {
            is: CaseSearch
        });
        document.body.appendChild(element);

        element.caseNumber = '12345';
        element.caseDetails = { caseNumber: '12345', subject: 'Test' };

        const buttons = element.shadowRoot.querySelectorAll('lightning-button');
        buttons[1].click(); // Clear button

        await new Promise(resolve => setTimeout(resolve, 0));

        expect(element.caseNumber).toBe('');
        expect(element.caseDetails).toBeNull();
        expect(element.hasError).toBe(false);
    });

    test('displays case details when search succeeds', async () => {
        const mockCaseData = [{
            found: true,
            caseNumber: '00001000',
            subject: 'Billing Issue',
            status: 'New',
            category: 'BILLING'
        }];

        getCaseDetails.mockResolvedValue(mockCaseData);

        const element = createElement('c-case-search', {
            is: CaseSearch
        });
        document.body.appendChild(element);

        element.caseNumber = '00001000';
        element.handleSearch();

        await new Promise(resolve => setTimeout(resolve, 100));

        expect(element.caseDetails).toEqual(mockCaseData[0]);
    });

    test('shows error when case not found', async () => {
        const mockCaseData = [{
            found: false,
            caseNumber: '99999999'
        }];

        getCaseDetails.mockResolvedValue(mockCaseData);

        const element = createElement('c-case-search', {
            is: CaseSearch
        });
        document.body.appendChild(element);

        element.caseNumber = '99999999';
        element.handleSearch();

        await new Promise(resolve => setTimeout(resolve, 100));

        expect(element.hasError).toBe(true);
        expect(element.caseDetails).toBeNull();
    });

    test('handles Apex method error gracefully', async () => {
        const mockError = new Error('Apex call failed');
        getCaseDetails.mockRejectedValue(mockError);

        const element = createElement('c-case-search', {
            is: CaseSearch
        });
        document.body.appendChild(element);

        const spyError = jest.spyOn(console, 'error').mockImplementation();

        element.caseNumber = '12345';
        element.handleSearch();

        await new Promise(resolve => setTimeout(resolve, 100));

        expect(spyError).toHaveBeenCalled();
        expect(element.hasError).toBe(true);
        expect(element.isLoading).toBe(false);

        spyError.mockRestore();
    });
});
