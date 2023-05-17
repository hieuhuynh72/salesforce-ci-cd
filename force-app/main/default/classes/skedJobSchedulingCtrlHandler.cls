public class skedJobSchedulingCtrlHandler extends skedJobSchedulingModel {

    /**
    *@description Get config data for Job Scheduling
    *
    */
    public skedResponse getDataConfig() {
        skedResponse response = new skedResponse();
        try {
            ConfigData configData = new ConfigData();

            response.success = true;
            response.data = configData;
        } catch ( Exception ex ) {
            response.getErrorMessage(ex);
        }
        return response;
    }

    /**
    *@description Get Opportunity Data
    *
    */
    public skedResponse getOpportunityData(String oppId) {
        skedResponse response = new skedResponse();
        try {
            List<Opportunity> opps = [
                SELECT Id, Name, AccountId, Account.Name, sked_Region__c, sked_Region__r.Name
                FROM Opportunity
                WHERE Id = :oppId
            ];

            OpportunityModel oppData;

            if (!opps.isEmpty()) {
                oppData = new OpportunityModel(opps[0]);
            }

            response.success = true;
            response.data = oppData;
        } catch ( Exception ex ) {
            response.getErrorMessage(ex);
        }
        return response;
    }

     /**
    *@description Get Account Data
    *
    */
    public skedResponse getAccountData(String accId) {
        skedResponse response = new skedResponse();
        try {
            List<Account> accs = [
                SELECT Id, Name, BillingAddress, sked_Region__c, sked_Region__r.Name, sked_Region__r.sked__Timezone__c,
                	BillingStreet, BillingCity, BillingState ,BillingPostalCode, BillingCountry,
					(SELECT Id, Name FROM Contacts LIMIT 1)
                FROM Account
                WHERE Id = :accId
            ];

            AccountModel accData;

            if (!accs.isEmpty()) {
                Account acc = accs[0];
                accData = new AccountModel(acc);
                String address = formatString(acc.BillingStreet) + formatString(acc.BillingCity) +  formatString(acc.BillingState) + formatString(acc.BillingPostalCode) + formatString(acc.BillingCountry);
                accData.jobLocation.fullAddress = String.isBlank(address) ? null : address.trim().normalizeSpace().removeEnd(',');
            }

            response.success = true;
            response.data = accData;
        } catch ( Exception ex ) {
            response.getErrorMessage(ex);
        }
        return response;
    }

    private String formatString(String input) {
        return String.isBlank(input) ? '' : input + ', ';
    }
    /**
    *@description Get suggested addresses from Google Place API
    * @input: address string
    *
    */
    public skedResponse getAddresses(String searchingText) {
        skedResponse response = new skedResponse();
        try {
            String sessionId = sked.SkeduloAPI.getSessionId();
            sked.ApiResult.AutoComplete result = sked.SkeduloAPI.autocomplete(searchingText, null, sessionId);
            if (!result.isSuccess()) {
                throw new skedModels.skedCoreException(result.message);
            }

            List<SuggestedAddressModel> suggestedAdds = new List<SuggestedAddressModel>();

            Map<String,String> resultMap = result.getResultMap();
            for (String placeId : resultMap.keySet()) {
                suggestedAdds.add(new SuggestedAddressModel(resultMap.get(placeId), placeId));
            }

            response.success = true;
            response.data = suggestedAdds;
        }
        catch ( Exception ex ) {
            response.getErrorMessage(ex);
        }
        return response;
    }

    /**
    *@description Get geolocation (lat & lon) from an address
    * @input: address string (placeId not used)
    *
    */
    public skedResponse getGeolocation(String address, String placeId) {
        skedResponse response = new skedResponse();
        try {
            sked.ApiResult.Geocode skedResponse = sked.SkeduloAPI.geocode(new List<String>{address});
            if (!skedResponse.isSuccess()) {
                throw new skedModels.skedCoreException(skedResponse.getError());
            }

            Location bookingLocation = skedResponse.result.get(0).getLocation();

            skedModels.customLocation location = new skedModels.customLocation(bookingLocation);
            response.success = true;
            response.data = location;
        } catch ( Exception ex ) {
            response.getErrorMessage(ex);
        }
        return response;
    }

    /**
    *@description Get available resources for booking grid
    *
    */
    public skedResponse getAvailableResources(Criteria criteria) {
        skedResponse response = new skedResponse();
        try {
            skedAvailatorParams params = new skedAvailatorParams(criteria);
            skedAvailator availator = new skedAvailator(params);

            List<skedModels.DateModel> bkDates = availator.getBookingDate();

            response.success = true;
            if (criteria.includeResourceInfo) {
                if (!bkDates.isEmpty() && !bkDates[0].timeSlots.isEmpty()) {
                    response.data = bkDates[0].timeSlots[0].availableResources;
                }
            } else {
                response.data = bkDates;
            }
        }
        catch ( Exception ex ) {
            response.getErrorMessage(ex);
        }
        return response;
    }

    /**
    *@description saveJob
    *
    */
    public skedResponse saveJob(Job jobModel) {
        SavePoint sp = Database.setSavepoint();
        skedResponse response = new skedResponse();
        try {
            handleSaveJob(jobModel);
            response = getJobDetails(jobModel.Id);
            response.success = true;
        }
        catch ( Exception ex ) {
            Database.rollback(sp);
            response.getErrorMessage(ex);
        }
        return response;
    }

    /**
    *@description getJobDetails
    *
    */
    public skedResponse getJobDetails(String jobId) {
        skedResponse response = new skedResponse();

        try {
            sked__Job__c skedJob = loadJobData(jobId);

            Job jobModel = null;
            if (skedJob != null) {
                jobModel = new Job(skedJob);
            }

            response.success = true;
            response.data = jobModel;
        }
        catch ( Exception ex ) {
            response.getErrorMessage(ex);
        }
        return response;
    }


    /**
    *@description Search homes by name and region
    *
    */
    public skedResponse searchHomes(String searchText, String regionId) {
        skedResponse response = new skedResponse();

        return response;
    }

    /**
    *@description Search suites by name and homeId
    *
    */
    public skedResponse searchSuites(String searchText, String homeId) {
        skedResponse response = new skedResponse();

        return response;
    }

    /**
    *@description Search homes by name and region
    *
    */
    public skedResponse searchRooms(String searchText, String homeId, String suiteId) {
        skedResponse response = new skedResponse();

        return response;
    }

    /**
    *@description Get cancellation reasons from Tour object
    *
    */
    public skedResponse getCancellationReasons() {
        skedResponse response = new skedResponse();

        try {

            List<skedModels.selectOption> reasons = new List<skedModels.selectOption>();//skedUtils.getPicklistValues('Tour__c', 'Cancellation_Reason__c');
            List<skedModels.cancellationOption> cancelReasons = new List<skedModels.cancellationOption>();

            for (skedModels.selectOption reason : reasons){
                skedModels.cancellationOption cancelReason = new skedModels.cancellationOption(reason.id, reason.label, reason.selected);
                if (skedConstants.TOUR_CANCELLED_REASON_OTHER.equalsIgnoreCase(reason.Id)){
                    cancelReason.requireComments = true;
                }
                cancelReasons.add(cancelReason);
            }
            response.success = true;
            response.data = cancelReasons;
        }
        catch ( Exception ex ) {
            response.getErrorMessage(ex);
        }
        return response;
    }

    /**
    *@description Get cancellation reasons from Tour object
    *
    */
    public skedResponse cancelTour(String tourId, String reason, String comments) {
        skedResponse response = new skedResponse();

        return response;
    }

    /**
    *@description Get list of tour from an opportunity
    *
    */
    public skedResponse getTourList(String opportunityId) {
        skedResponse response = new skedResponse();

        return response;
    }
////////////////////////////////////PRIVATE METHODS////////////////////////////////////////////////////////////////////////
    public void handleSaveJob(job jobModel) {
        sked__Job__c skedJob = jobModel.getSkedJob();

        if (String.isNotBlank(jobModel.Id)) {
            skedJob.Id  = jobModel.Id;
        } else {
            skedJob.sked__Job_Status__c = skedConstants.JOB_STATUS_PENDING_ALLOCATION;
        }

        upsert skedJob;

        jobModel.Id = skedJob.Id;
        // Process job allocation
        saveJobAllocations(jobModel);
    }

    private void saveJobAllocations(job jobModel) {

        List<sked__Job__c> skedJobs = [
            SELECT Id, Name,
            (   SELECT Id, sked__Resource__c
                FROM sked__Job_Allocations__r
                WHERE sked__Status__c NOT IN (:skedConstants.JOB_ALLOCATION_STATUS_DELETED))
            FROM sked__Job__c
            WHERE Id = :jobModel.id
        ];

        if (skedJobs.isEmpty()) {
            return;
        }

        sked__Job__c skedJob = skedJobs[0];

        List<sked__Job_Allocation__c> upsertAllocations = new List<sked__Job_Allocation__c>();
        // To check if allocation for a resource is kept
        Set<Id> keepResourceIds = new Set<Id>();
        Set<Id> allocatedResourceIds = new Set<Id>();
        sked__Job_Allocation__c newJobAlloc;
        String resourceId;

        for (sked__Job_Allocation__c currentAlloc : skedJob.sked__Job_Allocations__r) {
            allocatedResourceIds.add(currentAlloc.sked__Resource__c);
        }

        if (jobModel.allocations != null) {
            for (skedModels.jobAllocation alloc : jobModel.allocations) {
                resourceId = alloc.resource.id;
                if (allocatedResourceIds.contains(resourceId)) {
                    keepResourceIds.add(resourceId);
                } else {
                    newJobAlloc = new sked__Job_Allocation__c(
                        sked__Job__c = skedJob.id,
                        sked__Resource__c = resourceId,
                        sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DISPATCHED
                    );
                    upsertAllocations.add(newJobAlloc);
                }
            }
        }

        for(sked__Job_Allocation__c currentAlloc : skedJob.sked__Job_Allocations__r){
            if (!keepResourceIds.contains(currentAlloc.sked__Resource__c))
            {
                // change status to delete
                currentAlloc.sked__Status__c = skedConstants.JOB_ALLOCATION_STATUS_DELETED;
                upsertAllocations.add(currentAlloc);
            }
        }

        if (!upsertAllocations.isEmpty()) {
            upsert upsertAllocations;
        }
    }

    private sked__Job__c loadJobData(String jobId) {
        List<sked__Job__c> jobs = new List<sked__Job__c>();
        jobs = [
            SELECT Id, Name, sked__Account__c, sked__Account__r.Name, sked__Account__r.Id, sked__Start__c, sked__Finish__c, sked__Job_Status__c, /*sked_Off_Set_Time__c,*/
            sked__Timezone__c, sked__Address__c, sked__GeoLocation__c,
            sked__GeoLocation__latitude__s, sked__GeoLocation__longitude__s, sked__Region__c, sked__Region__r.Name, sked__Region__r.sked__Timezone__c,
            sked__Type__c, sked__Duration__c, sked__Description__c, /*sked_Custom_Description__c,*/ sked__Recurring_Schedule__c, sked__Contact__c, sked__Contact__r.Name,
            (
                SELECT Id, sked__Tag__c, sked__Tag__r.Name,sked__Tag__r.Id
                FROM sked__JobTags__r
            ),
            (
                SELECT Id, Name, sked__Status__c,
                sked__Resource__c, sked__Resource__r.Id, sked__Resource__r.Name, sked__Resource__r.sked__Primary_Region__c,
                sked__Resource__r.sked__Resource_Type__c,sked__Resource__r.sked__Category__c, sked__Resource__r.sked__GeoLocation__c,
                sked__Resource__r.sked__User__c, sked__Resource__r.sked__User__r.SmallPhotoUrl
                FROM sked__Job_Allocations__r
                WHERE sked__Status__c NOT IN (:skedConstants.JOB_ALLOCATION_STATUS_DELETED)
            )
            FROM sked__Job__c
            WHERE Id = :jobId
        ];

        if (jobs.isEmpty()) {
            return null;
        }
        return jobs[0];
    }

}