global class skedJobSchedulingCtrl {

    @remoteAction
    global static skedResponse getDataConfig() {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.getDataConfig();
    }

    @remoteAction
    global static skedResponse getAccountData(String accountId) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.getAccountData(accountId);
    }

    @remoteAction
    global static skedResponse getOpportunityData(String opportunityId) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.getOpportunityData(opportunityId);
    }

    @remoteAction
    global static skedResponse searchAddresses(String searchingText) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.getAddresses(searchingText);
    }

    @remoteAction
    global static skedResponse searchHomes(String searchingText, String regionId) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.searchHomes(searchingText, regionId);
    }

    @remoteAction
    global static skedResponse searchSuites(String searchingText, String homeId) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.searchSuites(searchingText, homeId);
    }

    @remoteAction
    global static skedResponse searchRooms(String searchingText, String homeId, String suiteId) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.searchRooms(searchingText, homeId, suiteId);
    }

    @remoteAction
    global static skedResponse getGeolocation(String address, String placeId) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.getGeolocation(address, placeId);
    }

    @remoteAction
    global static skedResponse searchContacts(String searchText) {
        return skedUtils.searchByName(searchText, 'Contact');
    }

    @remoteAction
    global static skedResponse searchAccounts(String searchText) {
        return skedUtils.searchByName(searchText, 'Account');
    }

    @remoteAction
    global static skedResponse getAvailableResources(skedJobSchedulingModel.Criteria criteria) {
        criteria.includeResourceInfo = true;
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.getAvailableResources(criteria);
    }

    @remoteAction
    global static skedResponse getBookingGridData(skedJobSchedulingModel.Criteria criteria) {
        criteria.includeResourceInfo = false;
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.getAvailableResources(criteria);
    }

    @remoteAction
    global static skedResponse saveJob(skedJobSchedulingModel.Job jobModel) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.saveJob(jobModel);
    }

    @remoteAction
    global static skedResponse getJobDetails(String jobId) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.getJobDetails(jobId);
    }

    @remoteAction
    global static skedResponse getCancellationReasons() {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.getCancellationReasons();
    }


    @remoteAction
    global static skedResponse cancelTour(String tourId, String reason, String comments) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.cancelTour(tourId, reason, comments);
    }

    @remoteAction
    global static skedResponse getTourList(String opportunityId) {
        skedJobSchedulingCtrlHandler handler = new skedJobSchedulingCtrlHandler();
        return handler.getTourList(opportunityId);
    }
}