@RestResource(urlMapping='/ContactAPI/*')
global class UpdateContactRESTApi {
    // Create wrapper of response class
    global class ResponseWrapper {
        String success;
        String message;
        Integer statusCode;
    }

    // PATCH method
    @HttpPatch
    global static List<ResponseWrapper> updateContacts() {
        List<ResponseWrapper> responseWrapperList = new List<ResponseWrapper>();
        RestRequest req = RestContext.Request;
        String requestBody = req.requestBody.toString();
        List<Contact> listContacts = (List<Contact>) JSON.deserialize(requestBody, List<Contact>.class);
        List<Contact> listContactsUpdate = new List<Contact>();
        ResponseWrapper responseWrapper;

        // Validate input contacts Id
        for (Contact contact : listContacts) {
            responseWrapper = new ResponseWrapper();
            String tempId = contact.Id;
            List<Contact> tempContact = Database.query('SELECT Id FROM Contact WHERE Id = :tempId');

            if (tempContact != null && tempContact.size() > 0) {
                listContactsUpdate.add(contact);
            } else {
                responseWrapper.success = '0';
                responseWrapper.message = 'The error has occurred for contact with Id: ' + contact.Id
                + ' The input contacts should exist in the system.';
                responseWrapper.statusCode = 422;
            }

            // Add response validate error to response list
            if (responseWrapper != NULL && responseWrapper.success != NULL) {
                responseWrapperList.add(responseWrapper);
            }
        }


        // Update contacts
        Database.SaveResult[] updateResults = Database.update(listContactsUpdate, false);

        // Check results
        for (Database.SaveResult updateResult : updateResults) {
            responseWrapper = new ResponseWrapper();
            if (updateResult.isSuccess()) {
                // Update successful
                responseWrapper.success = '1';
                responseWrapper.message = 'Successfully updated contact with Id: ' + updateResult.getId() + '.';
                responseWrapper.statusCode = 200;
            } else {
                // Update failed
                responseWrapper.success = '0';
                for (Database.Error error : updateResult.getErrors()) {
                    responseWrapper.message = 'The error has occurred for contact with Id: ' + updateResult.getId()
                        + ' ' + error.getStatusCode() + ': ' + error.getMessage() + '.';
                }
                responseWrapper.statusCode = 500;
            }

            // Add response to response list
            if (responseWrapper != NULL && responseWrapper.success != NULL) {
                responseWrapperList.add(responseWrapper);
            }
        }

        return responseWrapperList;
    }
}