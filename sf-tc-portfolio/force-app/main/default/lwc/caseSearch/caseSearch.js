import { LightningElement, track } from 'lwc';
import getCaseDetails from '@salesforce/apex/CaseAgentActions.getCaseDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseSearch extends LightningElement {
    @track caseNumber = '';
    @track caseDetails = null;
    @track isLoading = false;
    @track hasError = false;

    handleInputChange(event) {
        this.caseNumber = event.target.value;
    }

    async handleSearch() {
        if (!this.caseNumber || this.caseNumber.trim() === '') {
            this.showToast('Error', 'Please enter a case number', 'error');
            return;
        }

        this.isLoading = true;
        this.hasError = false;

        try {
            const result = await getCaseDetails({ caseNumbers: [this.caseNumber] });
            
            if (result && result.length > 0) {
                const detail = result[0];
                if (detail.found) {
                    this.caseDetails = detail;
                    this.showToast('Success', `Case ${this.caseNumber} found`, 'success');
                } else {
                    this.hasError = true;
                    this.caseDetails = null;
                    this.showToast('Not Found', `Case ${this.caseNumber} does not exist`, 'warning');
                }
            }
        } catch (error) {
            this.hasError = true;
            this.caseDetails = null;
            this.showToast('Error', 'Failed to retrieve case details', 'error');
            console.error('Error searching case:', error);
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    handleClear() {
        this.caseNumber = '';
        this.caseDetails = null;
        this.hasError = false;
    }
}
