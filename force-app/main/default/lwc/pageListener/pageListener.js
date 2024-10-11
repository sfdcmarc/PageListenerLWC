import { LightningElement, api, wire, track } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getFlexiPageMetadata from '@salesforce/apex/FlexiPageMetadataService.getFlexiPageMetadata';
import { getRecord } from 'lightning/uiRecordApi';

export default class PageListener extends LightningElement {
    @api recordId;
	@api objectApiName = '';
    @api flexiPageName = 'DefaultPageName'; // Set a default value

    _fields = [];
    wiredRecordResult; // Store the wire result

    // Reactive property to track when fields are ready
    fieldsReady = false;

	// Getter and setter for fields
    get fields() {
        return this._fields;
    }

    set fields(value) {
        this._fields = value;
    }

	get reactiveRecordId() {
		console.log('Reactive record ID: ', this.recordId);
		console.log('Object API Name: ', this.objectApiName);
		return this.recordId;
	}

    // Wire to call the Apex method
    @wire(getFlexiPageMetadata, { developerName: '$flexiPageName' })
    wiredMetadata({ error, data }) {
        if (data) {
            try {
                const metadata = JSON.parse(data);
                this.fields = metadata.flexiPageRegions
                    .flatMap(region => region.itemInstances)
                    .filter(item => item.fieldInstance)
                    .map(item => {
                        const fieldItem = item.fieldInstance.fieldItem;
                        return this.objectApiName + '.' + (fieldItem.startsWith('Record.') ? fieldItem.split('Record.')[1] : fieldItem);
                    });

    			this.fieldsReady = true; // Set fieldsReady to true when fields are set

                console.log('Extracted fields:', JSON.stringify(this.fields));
            } catch (e) {
                console.error('Error parsing metadata:', e);
            }
        } else if (error) {
            console.error('Error retrieving metadata:', error);
        }
    }

    // Wire to call the getRecord method with the fields populated from the Apex method
    @wire(getRecord, { recordId: '$reactiveRecordId', fields: '$fields' })
    wiredRecord(result) {
		console.log('Fields: ', JSON.stringify(this.fields));
        if (this.fieldsReady) { // Ensure this runs only when fields are ready
            this.wiredRecordResult = result; // Store the result for refresh
            if (result.data) {
                // Notify LDS that the record has been updated
                getRecordNotifyChange([{ recordId: this.recordId }]);
            }
        }
    }
}