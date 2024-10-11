public class FlexiPageMetadataService {
    // Defines the version of the Tooling API to use
    public static final String TOOLING_API_VERSION = 'v60.0';

    /**
     * Retrieves the metadata for a specified FlexiPage based on its developer name.
     *
     * @param developerName The developer name of the FlexiPage to retrieve metadata for.
     * @return A JSON string representing the metadata of the specified FlexiPage.
     * @throws AuraHandledException if an error occurs while retrieving the metadata.
     */
    @AuraEnabled(cacheable=true)
    public static String getFlexiPageMetadata(String developerName) {
        try {
            // Log entry into the method
            // Logger.info('Entering getFlexiPageMetadata method');

            // Construct the SOQL query to fetch metadata for the specified FlexiPage
            String query = 'SELECT Metadata FROM FlexiPage WHERE DeveloperName = \'' + developerName + '\'';
            // Logger.info('Query: ' + query);

            // Setup the HTTP request for the Tooling API call
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Tooling_API_Credential/services/data/' + TOOLING_API_VERSION + '/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
            request.setMethod('GET');
            // Logger.info('HttpRequest: ' + request);

            // Send the HTTP request
            Http http = new Http();
            HttpResponse response = http.send(request);
            // Logger.info('HttpResponse Status: ' + response.getStatus());
            // Logger.info('HttpResponse Body: ' + response.getBody());

            // Check if the response status is 200 (OK)
            if (response.getStatusCode() == 200) {
                // Handle the successful response
                return handleFlexiPageResponse(response.getBody());
            } else {
                // Log and throw an error for unsuccessful responses
                // Logger.error('Error response from API: ' + response.getStatus());
                // Logger.error('Error response body: ' + response.getBody());
                throw new AuraHandledException('Error retrieving FlexiPage metadata');
            }
        } catch (Exception e) {
            // Log and throw an exception if an error occurs
            // Logger.error('Exception in getFlexiPageMetadata', e);
            throw new AuraHandledException('Exception in getFlexiPageMetadata: ' + e.getMessage());
        } finally {
            // Ensure logs are saved
            // Logger.saveLog();
        }
    }

        /**
     * Handles the response from the Tooling API and extracts the FlexiPage metadata.
     *
     * @param responseBody The response body from the Tooling API call.
     * @return A JSON string representing the metadata of the FlexiPage.
     * @throws AuraHandledException if an error occurs while processing the response.
     */
    private static String handleFlexiPageResponse(String responseBody) {
        try {
            // Log entry into the method
            // Logger.info('Entering handleFlexiPageResponse method');
            // Logger.info('Response Body: ' + responseBody);

            // Parse the JSON response body into a Map
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            // Logger.info('Response body parsed: ' + JSON.serialize(result));

            // Extract records from the result
            List<Object> records = (List<Object>) result.get('records');
            if (records != null && !records.isEmpty()) {
                // Extract metadata from the first record
                Map<String, Object> firstRecord = (Map<String, Object>) records[0];
                Map<String, Object> metadata = (Map<String, Object>) firstRecord.get('Metadata');
                // Logger.info('Metadata: ' + JSON.serialize(metadata));

                // Return the metadata as a JSON string
                return JSON.serialize(metadata);
            } else {
                // Throw an error if no records are found
                throw new AuraHandledException('No records found for the specified FlexiPage');
            }
        } catch (Exception e) {
            // Log and throw an exception if an error occurs
            // Logger.error('Exception in handleFlexiPageResponse', e);
            throw new AuraHandledException('Exception in handleFlexiPageResponse: ' + e.getMessage());
        } finally {
            // Ensure logs are saved
            // Logger.saveLog();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ObjectInfo> getObjects() {
        List<ObjectInfo> objects = new List<ObjectInfo>();
        for (Schema.SObjectType objType : Schema.getGlobalDescribe().values()) {
            Schema.DescribeSObjectResult describeResult = objType.getDescribe();
            if (describeResult.isAccessible() && describeResult.isCreateable()) {
                objects.add(new ObjectInfo(describeResult.getLabel(), describeResult.getName()));
            }
        }
        return objects;
    }

    public class ObjectInfo {
        @AuraEnabled public String label;
        @AuraEnabled public String apiName;

        public ObjectInfo(String label, String apiName) {
            this.label = label;
            this.apiName = apiName;
        }
    }
}