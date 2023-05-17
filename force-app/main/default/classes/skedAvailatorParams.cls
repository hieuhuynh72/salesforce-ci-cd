global class skedAvailatorParams {

    public String timezoneSidId {get;set;}
    public Set<Id> homeIds {get;set;}
    public Set<Id> suiteIds {get;set;}
    public Set<Id> roomIds {get;set;}
    public Set<Id> regionIds {get;set;}
    public Set<Id> resourceIds {get;set;}
    public Set<Id> excludedJobIds {get;set;}
    public List<skedModels.job> inputJobs {get;set;}
    public Boolean includeResourceInfo{get;set;}
    public boolean onlyKeepQualifiedResources {get;set;}

    public skedAvailatorParams() {
        this.timezoneSidId = UserInfo.getTimeZone().getID();
        this.regionIds = new Set<Id>();
        this.homeIds = new Set<Id>();
        this.suiteIds = new Set<Id>();
        this.roomIds = new Set<Id>();
        this.resourceIds = new Set<Id>();
        this.excludedJobIds = new Set<Id>();
        this.inputJobs = new List<skedModels.job>();
        this.onlyKeepQualifiedResources = false;
        this.includeResourceInfo = false;
    }

    public skedAvailatorParams(skedJobSchedulingModel.Criteria criteria) {
        this();

        this.includeResourceInfo = criteria.includeResourceInfo;
        this.regionIds.add(criteria.regionId);
        this.homeIds.add(criteria.homeId);
        if (String.isNotBlank(criteria.suiteId)) {
            this.suiteIds.add(criteria.suiteId);
        }
        if (String.isNotBlank(criteria.roomId)) {
            this.roomIds.add(criteria.roomId);
        }
        this.timezoneSidId = criteria.timeZone;

        List<skedBaseModels.tag> requiredTags = new List<skedBaseModels.tag>();

        if (criteria.tagIds != null && !criteria.tagIds.isEmpty()) {
            for (string tagId : criteria.tagIds) {
                skedBaseModels.tag tag = new skedBaseModels.tag();
                tag.id = tagId;
                requiredTags.add(tag);
            }
        }

        Location jobLocation = Location.newInstance(criteria.latitude, criteria.longitude);
        DateTime startOfDay = skedDateTimeUtils.getStartOfDate(criteria.startDate, criteria.timeZone);
        DateTime endOfDay = skedDateTimeUtils.getStartOfDate(criteria.endDate, criteria.timeZone);
        DateTime tempDate = startOfDay;

        Integer startWorkingTimeInMinutes = 700;
        Integer endWorkingTimeInMinutes = 1600;

        if (criteria.includeResourceInfo) {
            // get available resources
            startWorkingTimeInMinutes = skedDateTimeUtils.ConvertTimeNumberToMinutes(criteria.intStartTime);
            endWorkingTimeInMinutes = skedDateTimeUtils.ConvertTimeNumberToMinutes(criteria.intEndTime);
            endOfDay = startOfDay;
        } else {
            skedConfigs__c configs = skedConfigs.getSkedConfigsSettings();
            if (configs != null) {
                startWorkingTimeInMinutes = configs.Start_Working_Time__c == null ? startWorkingTimeInMinutes : (Integer)configs.Start_Working_Time__c;
                endWorkingTimeInMinutes = configs.End_Working_Time__c == null ? endWorkingTimeInMinutes : (Integer)configs.End_Working_Time__c;
            }
            startWorkingTimeInMinutes = skedDateTimeUtils.ConvertTimeNumberToMinutes(startWorkingTimeInMinutes);
            endWorkingTimeInMinutes = skedDateTimeUtils.ConvertTimeNumberToMinutes(endWorkingTimeInMinutes);
        }

        List<skedModels.job> possibleJobs = new List<skedModels.job>();
        skedModels.job possibleJob;
        List<skedModels.TimeSlotModel> timeSlots;

        while(tempDate <= endOfDay) {
            for (skedModels.TimeSlotModel timeSlot : getSlots(tempDate, criteria, startWorkingTimeInMinutes, endWorkingTimeInMinutes)) {
                possibleJob = new skedModels.job();
                possibleJob.start = timeSlot.startTimeValue;
                possibleJob.finish = timeSlot.endTimeValue;
                possibleJob.geoLocation = jobLocation;
                possibleJob.tags = new List<skedBaseModels.tag>();
                possibleJob.tags.addAll(requiredTags);
                possibleJobs.add(possibleJob);
            }
            tempDate = skedDateTimeUtils.addDays(tempDate, 1, criteria.timeZone);
        }

        possibleJobs.sort();
        this.inputJobs = possibleJobs;

        if (criteria.eventIds != null && !criteria.eventIds.isEmpty()) {
            this.excludedJobIds = new Set<Id>(criteria.eventIds);
        }
    }

    private List<skedModels.TimeSlotModel> getSlots(DateTime startOfDate, skedJobSchedulingModel.Criteria criteria, Integer startWorkingTimeInMinutes, Integer endWorkingTimeInMinutes) {
        List<skedModels.TimeSlotModel> timeSlots = new List<skedModels.TimeSlotModel>();
        skedModels.TimeSlotModel timeSlot;

        DateTime startWorkingTime = skedDateTimeUtils.addMinutes(startOfDate, startWorkingTimeInMinutes, criteria.timeZone);
        // COM-83 revert
        /*if (criteria.offsetTime != null && criteria.offsetTime > 0 && criteria.includeResourceInfo == false) {
            startWorkingTime = skedDateTimeUtils.addMinutes(startWorkingTime, criteria.offsetTime, criteria.timeZone);
        }*/

        DateTime endWorkingTime = skedDateTimeUtils.addMinutes(startOfDate, endWorkingTimeInMinutes, criteria.timeZone);

        if (criteria.includeResourceInfo) {
            // for get available resources
            timeSlot = new skedModels.TimeSlotModel();
            timeSlot.startTimeValue = startWorkingTime;
            timeSlot.endTimeValue = endWorkingTime;
            timeSlots.add(timeSlot);
        } else {
            // for booking grid
            DateTime tempFinishTime = startWorkingTime;

            while (startWorkingTime < endWorkingTime) {
                tempFinishTime = skedDateTimeUtils.addMinutes(startWorkingTime, criteria.duration, criteria.timeZone);
                if (tempFinishTime <= endWorkingTime) {
                    timeSlot = new skedModels.TimeSlotModel();
                    timeSlot.startTimeValue = startWorkingTime;
                    timeSlot.endTimeValue = tempFinishTime;
                    timeSlots.add(timeSlot);
                }
                startWorkingTime = tempFinishTime;
            }
        }

        return timeSlots;
    }
}