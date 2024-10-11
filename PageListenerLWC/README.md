# PageListener LWC

## Overview

`PageListener` is a Lightning Web Component (LWC) designed to listen for updates to Salesforce records and retrieve metadata from a specified flexi page. It leverages Lightning Data Service (LDS) to manage data efficiently, ensuring the component reflects the most current information from the Salesforce database. This component can be used in a "headless" manner, making it suitable for inclusion in a Lightning Record Page without being nested inside another LWC.

## Features

- **Dynamic Field Extraction**: Automatically extracts fields defined in the specified flexi page.
- **Reactive Record Handling**: Monitors and updates the record data based on changes in the record ID.
- **Metadata Retrieval**: Retrieves flexi page metadata using an Apex service to configure fields dynamically.
- **Change Data Capture Support**: Listens for changes in Salesforce records and updates the component accordingly.

## Installation

1. **Clone the repository** (if applicable):

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Add the component to your Salesforce org**:

Use the Salesforce CLI or Developer Console to deploy the component.
```bash
sfdx force:source:push
```

Ensure the Apex class FlexiPageMetadataService is deployed to your Salesforce org as it is required for metadata retrieval.

**Usage**
To use the PageListener component in your Lightning app or record page:

**Included in a Lightning Record Page**
1. Include the component in your Lightning page:

```html
<c-page-listener record-id={recordId} object-api-name="YourObjectApiName" flexi-page-name="YourFlexiPageName"></c-page-listener>
```
2. Set the necessary properties:

- **recordId**: The ID of the record to monitor.
- **objectApiName**: The API name of the object associated with the record.
- **flexiPageName**: The developer name of the flexi page from which to retrieve metadata (optional, defaults to 'DefaultPageName').

**Headless Usage**
The PageListener component can also be used in a headless manner within a Lightning Record Page. In this scenario, you do not need to wrap the component inside another LWC; simply include it directly on the record page.

**Change Data Capture**
The component listens for changes to the record data using [Change Data Capture](https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/platform_events_objects_change_data_capture.htm) (CDC). This allows it to react to updates and ensure the displayed information remains current. Make sure to configure CDC for the relevant objects in your Salesforce org.

**Properties**
- **recordId** (String): The ID of the Salesforce record to listen to.
- **objectApiName** (String): The API name of the object (required).
- **flexiPageName** (String): The developer name of the flexi page to retrieve metadata (optional).

**Functionality**
- The component uses the @wire decorator to call the Apex method getFlexiPageMetadata to retrieve metadata based on the flexiPageName.
- It extracts fields dynamically and stores them in the _fields property, which is reactive to changes.
- The getRecord method from Lightning Data Service is used to retrieve record data based on the dynamic fields extracted from the flexi page.
- The component calls getRecordNotifyChange to notify the Lightning Data Service when the record has been updated.
- Change Data Capture channels can be configured to ensure the component responds to updates in real-time.
- Apex Class: `FlexiPageMetadataService`
- The component relies on the FlexiPageMetadataService Apex class, which provides methods to retrieve flexi page metadata and object information. Key methods include:

- **getFlexiPageMetadata**(String developerName): Retrieves the metadata for a specified flexi page based on its developer name.
- **handleFlexiPageResponse**(String responseBody): Processes the response from the Tooling API and extracts the flexi page metadata.
- **getObjects()**: Returns a list of accessible and creatable objects in the org.

**Error Handling**
Errors during metadata retrieval and JSON parsing are logged to the console to assist in troubleshooting.

**Logging**
The component includes console logging for debugging purposes. You can view logs for:
- Reactive record ID and object API name.
- Extracted fields from the flexi page metadata.
- Wired record results.


**License**
This project is licensed under the [MIT License]().