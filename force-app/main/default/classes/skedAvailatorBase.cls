global abstract class skedAvailatorBase {

    protected skedAvailatorParams params {get;set;}

    protected skedResourceAvailabilityBase resourceAvailability {
        get {
            if (resourceAvailability == NULL) {
                resourceAvailability = new skedResourceAvailability();
            }
            return resourceAvailability;
        }
        set;
    }

    protected skedTravelTimeServiceBase travelTimeService {
        get {
            if (travelTimeService == NULL) {
                travelTimeService = new skedTravelTimeService();
            }
            return travelTimeService;
        }
        set;
    }

    protected Map<Id, skedResourceAvailabilityBase.resourceModel> mapResource {get;set;}

    protected List<skedModels.jobAllocation> allAllocations {get;set;}

    /*********************************************************Constructor***************************************************/
    public skedAvailatorBase(skedAvailatorParams inputParams) {
        this.params = inputParams;
        initialize();
    }

    /*********************************************************for availability validation***************************************************/
    private void initialize() {
        DateTime firstJobStart, lastJobFinish;
        Date firstJobStartDate, lastJobFinishDate;
        List<skedModels.job> allJobs = new List<skedModels.job>();
        for (skedModels.job job : params.inputJobs) {
            allJobs.add(job);
            if (job.followups != NULL && !job.followups.isEmpty()) {
                allJobs.addAll(job.followups);
            }
        }
        for (skedModels.job job : allJobs) {
            if (firstJobStart == NULL || firstJobStart > job.start) {
                firstJobStart = job.start;
            }
            if (lastJobFinish == NULL || lastJobFinish < job.finish) {
                lastJobFinish = job.finish;
            }
        }

        if (params.resourceIds.isEmpty() && !params.regionIds.isEmpty() && !params.homeIds.isEmpty()) {
            firstJobStartDate = skedDateTimeUtils.getDate(firstJobStart, params.timezoneSidId);
            lastJobFinishDate = skedDateTimeUtils.getDate(lastJobFinish, params.timezoneSidId);
            //get all resource that allocated for home
            Set<Id> resourceHomeIds = new Set<Id>();

            Map<Id, sked__Resource__c> mapSkedResource = new Map<Id, sked__Resource__c>([
                SELECT Id,
                (
                    SELECT Id
                    FROM sked__Job_Allocations__r
                    WHERE sked__Job__c IN :params.excludedJobIds
                    AND sked__Status__c NOT IN (:skedConstants.JOB_ALLOCATION_STATUS_DELETED)
                )
                FROM sked__Resource__c
                WHERE /*Id IN :resourceHomeIds AND*/ sked__Is_Active__c = TRUE
            ]);

            params.resourceIds = new Set<Id>();
            for (sked__Resource__c res : mapSkedResource.values()) {
                params.resourceIds.add(res.Id);
            }
        }
        this.mapResource = this.resourceAvailability.initializeResourceList(params.resourceIds, firstJobStart, lastJobFinish, params.timezoneSidId, params.homeIds);
        initializeOtherResourceData();
        this.allAllocations = new List<skedModels.jobAllocation>();
    }

    /*********************************************************Count available resources***************************************************/
    public void validateJobs() {
        List<skedModels.jobAllocation> possibleAllocations = getPossibleAllocations(mapResource.values(), params.inputJobs);

        postProcessPossibleAllocations();

        validateAvailability(possibleAllocations, params.excludedJobIds);
    }

    /*********************************************************Protected methods***************************************************/
    protected virtual void initializeOtherResourceData() {

    }

    protected virtual void postProcessPossibleAllocations() {

    }
    /*********************************************************Validate allocation stuffs***************************************************/
    /*
    private void validateAvailability(List<skedModels.jobAllocation> inputAllocations) {
        validateAvailability(inputAllocations, new Set<Id>());
    }

    private void validateAvailability(List<skedModels.jobAllocation> inputAllocations, Id excludeJobId) {
        Set<Id> excludeJobIds = new Set<Id>();
        excludeJobIds.add(excludeJobId);
        validateAvailability(inputAllocations, excludeJobIds);
    }
    */
    private void validateAvailability(List<skedModels.jobAllocation> inputAllocations, Set<Id> excludeJobIds) {
        if (inputAllocations == NULL || inputAllocations.isEmpty()) {
            return;
        }
        this.allAllocations = new List<skedModels.jobAllocation>();

        for (skedModels.jobAllocation allocation : inputAllocations) {
            skedResourceAvailabilityBase.resourceModel resource = this.mapResource.get(allocation.resourceId);
            allocation.resource = resource;
            validateAllocation(allocation, resource, excludeJobIds);

            if (this.params.onlyKeepQualifiedResources) {
                if (allocation.isQualified == true) {
                    this.allAllocations.add(allocation);
                }
            }
            else {
                this.allAllocations.add(allocation);
            }
        }

        //handle travel time conflict
        Map<string, skedBaseModels.geometry> mapOrigin = new Map<string, skedBaseModels.geometry>();
        Map<string, skedBaseModels.geometry> mapDestination = new Map<string, skedBaseModels.geometry>();

        for (skedModels.jobAllocation allocation : inputAllocations) {
            if (!allocation.isQualified || !allocation.isAvailable) {
                continue;
            }
            if (allocation.job.geoLocation != NULL) {
                if (allocation.previousEvent != NULL && allocation.previousEvent.geoLocation != NULL) {
                    allocation.startFromLocation = new skedBaseModels.geometry(allocation.previousEvent.geoLocation);
                    skedBaseModels.geometry origin = new skedBaseModels.geometry(allocation.previousEvent.geoLocation);
                    mapOrigin.put(origin.lat + ',' + origin.lng, origin);

                    skedBaseModels.geometry destination = new skedBaseModels.geometry(allocation.job.geoLocation);
                    mapDestination.put(destination.lat + ',' + destination.lng, destination);
                }
                else {
                    if (allocation.resource.geoLocation != NULL) {
                        allocation.startFromLocation = new skedBaseModels.geometry(allocation.resource.geoLocation);
                        skedBaseModels.geometry origin = new skedBaseModels.geometry(allocation.resource.geoLocation);
                        mapOrigin.put(origin.lat + ',' + origin.lng, origin);

                        skedBaseModels.geometry destination = new skedBaseModels.geometry(allocation.job.geoLocation);
                        mapDestination.put(destination.lat + ',' + destination.lng, destination);
                    } else {
                        allocation.noHomeAddress = true;
                    }
                }
                if (allocation.nextEvent != NULL && allocation.nextEvent.geoLocation != NULL) {
                    skedBaseModels.geometry origin = new skedBaseModels.geometry(allocation.job.geoLocation);
                    mapOrigin.put(origin.lat + ',' + origin.lng, origin);

                    skedBaseModels.geometry destination = new skedBaseModels.geometry(allocation.nextEvent.geoLocation);
                    mapDestination.put(destination.lat + ',' + destination.lng, destination);
                }
            }
        }

        //this need to change to use crow flies distance // google matrix // other service.
        this.travelTimeService.initialize(mapOrigin.values(), mapDestination.values());

        for (skedModels.jobAllocation allocation : inputAllocations) {
            if (!allocation.isAvailable) {
                continue;
            }
            if (allocation.job.geoLocation != NULL) {
                if (allocation.previousEvent != NULL && allocation.previousEvent.geoLocation != NULL) {
                    skedBaseModels.journeyModel journey = this.travelTimeService.getJourney(allocation.previousEvent.geoLocation, allocation.job.geoLocation);
                    if (journey != NULL) {
                        if (journey.travelTime == NULL || journey.distance == NULL) {
                            allocation.isAvailable = false;
                            allocation.conflictDetails = 'Resource cannot get to this location.';
                        }
                        else {
                            allocation.travelTime = (journey.travelTime / 60);
                            allocation.distance = journey.distance;
                            allocation.distanceInMiles = journey.distanceInMiles;

                            if (allocation.previousEvent.finish.addMinutes(allocation.travelTime) > allocation.job.start) {
                                allocation.isAvailable = false;
                            }
                        }
                    }
                }
                else {
                    if (allocation.resource.geoLocation != NULL) {
                        skedBaseModels.journeyModel journey = this.travelTimeService.getJourney(allocation.resource.geoLocation, allocation.job.geoLocation);
                        if (journey != NULL) {
                            if (journey.travelTime == NULL || journey.distance == NULL) {
                                allocation.isAvailable = false;
                                allocation.conflictDetails = 'Resource cannot get to this location.';
                            }
                            else {
                                allocation.travelTime = (journey.travelTime / 60);
                                allocation.distance = journey.distance;
                                allocation.distanceInMiles = journey.distanceInMiles;
                            }
                        }
                    } else {
                        allocation.noHomeAddress = true;
                    }
                }
                if (allocation.nextEvent != NULL && allocation.nextEvent.geoLocation != NULL) {
                    skedBaseModels.journeyModel journey = this.travelTimeService.getJourney(allocation.job.geoLocation, allocation.nextEvent.geoLocation);
                    if (journey != NULL) {
                        if (journey.travelTime == NULL || journey.distance == NULL) {
                            allocation.isAvailable = false;
                            allocation.conflictDetails = 'Resource cannot get to this location.';
                        }
                        else {
                            integer travelTimeTo = (journey.travelTime / 60);

                            if (allocation.job.finish.addMinutes(travelTimeTo) > allocation.nextEvent.start) {
                                allocation.isAvailable = false;
                            }
                        }
                    }
                }
            }
        }
    }

    private void validateAllocation(skedModels.jobAllocation allocation, skedResourceAvailabilityBase.resourceModel resource, Set<Id> excludeJobIds) {
        if (allocation.isQualified == false) {
            return;
        }

        for (skedBaseModels.event event : resource.allEvents) {
            if (allocation.job.finish < event.start && allocation.nextEvent != NULL) {
                break;
            }
            if (event.id != NULL && excludeJobIds != NULL && !excludeJobIds.isEmpty()) {
                if (event.eventType == 'jobAllocation') {
                    string jobId = ((skedModels.jobAllocation)event).jobId;
                    if (excludeJobIds.contains(jobId)) {
                        continue;
                    }
                }
            }
            if (event.start < allocation.job.finish && event.finish > allocation.job.start) {
                allocation.isAvailable = false;
                handleConflict(allocation, event);
                if (event.eventType == 'non-working') {
                    allocation.isQualified = false;
                }
                break;
            }
            if (event.finish <= allocation.job.start) {
                allocation.previousEvent = event;
            }

            if (event.start >= allocation.job.finish) {
                allocation.nextEvent = event;
            }
        }
    }

    protected void validateAllocationWithTravelTime(skedModels.jobAllocation allocation, skedResourceAvailabilityBase.resourceModel resource, Set<Id> excludeJobIds) {
        skedBaseModels.event previousEvent, nextEvent;
        for (skedBaseModels.event event : resource.allEvents) {
            if (allocation.job.finish < event.start && nextEvent != NULL) {
                break;
            }
            if (event.id != NULL && excludeJobIds != NULL && !excludeJobIds.isEmpty()) {
                if (event.eventType == 'jobAllocation') {
                    string jobId = ((skedModels.jobAllocation)event).jobId;
                    if (excludeJobIds.contains(jobId)) {
                        continue;
                    }
                }
            }
            if (event.start < allocation.job.finish && event.finish > allocation.job.start) {
                allocation.isAvailable = false;
                handleConflict(allocation, event);
                if (event.eventType == 'non-working') {
                    allocation.isQualified = false;
                }
                break;
            }
            if (event.finish <= allocation.job.start) {
                previousEvent = event;
            }
            if (event.start >= allocation.job.finish) {
                nextEvent = event;
            }
        }
        if (allocation.job.geoLocation != NULL) {
            if (previousEvent != NULL && previousEvent.geoLocation != NULL) {
                allocation.startFromLocation = new skedBaseModels.geometry(previousEvent.geoLocation);
                integer travelTimeFrom = getTravelTime(previousEvent.geoLocation, allocation.job.geoLocation);
                allocation.travelTime = travelTimeFrom;
                allocation.distance = previousEvent.geoLocation.getDistance(allocation.job.geoLocation, 'km');
                allocation.distanceInMiles = previousEvent.geoLocation.getDistance(allocation.job.geoLocation, 'mi');
                if (previousEvent.finish.addMinutes(travelTimeFrom) > allocation.job.start) {
                    allocation.isAvailable = false;
                    handleConflict(allocation, previousEvent);
                }
            } else {
                if (resource.geoLocation != NULL) {
                    allocation.startFromLocation = new skedBaseModels.geometry(resource.geoLocation);
                    allocation.distance = resource.geoLocation.getDistance(allocation.job.geoLocation, 'km');
                    allocation.distanceInMiles = resource.geoLocation.getDistance(allocation.job.geoLocation, 'mi');
                    allocation.travelTime = getTravelTime(resource.geoLocation, allocation.job.geoLocation);
                } else {
                    allocation.noHomeAddress = true;
                }
            }
            if (nextEvent != NULL && nextEvent.geoLocation != NULL) {
                integer travelTimeTo = getTravelTime(allocation.job.geoLocation, nextEvent.geoLocation);
                if (allocation.job.finish.addMinutes(travelTimeTo) > nextEvent.start) {
                    allocation.isAvailable = false;
                    handleConflict(allocation, nextEvent);
                }
            }
        }
    }

    protected virtual List<skedModels.jobAllocation> getPossibleAllocations(List<skedResourceAvailabilityBase.resourceModel> resources, List<skedModels.job> inputJobs) {
        List<skedModels.jobAllocation> result = new List<skedModels.jobAllocation>();

        for (skedModels.job job : inputJobs) {
            /*
            List<string> requiredTagIds = new List<string>();
            if (job.tags != NULL && !job.tags.isEmpty()) {
                for (skedBaseModels.tag jobTag : job.tags) {
                    requiredTagIds.add(jobTag.id);
                }
            }
            */
            for (skedResourceAvailabilityBase.resourceModel resource : resources) {
                skedModels.jobAllocation allocation = new skedModels.jobAllocation();
                allocation.resource = resource;
                allocation.resourceId = resource.id;
                allocation.job = job;
                allocation.jobId = job.id;

            /*
                if (requiredTagIds.size() > 0) {
                    Set<string> resourceTagIds = new Set<string>();
                    for (skedBaseModels.tag resourceTag : resource.tags) {
                        if (resourceTag.expiryTime == NULL || job.finish <= resourceTag.expiryTime) {
                            resourceTagIds.add(resourceTag.id);
                        }
                    }

                    allocation.isQualified = resourceTagIds.containsAll(requiredTagIds);
                    if (allocation.isQualified == false) {
                        allocation.conflictDetails = 'Resource does not have all of required tags.';
                    }
                }
            */
                result.add(allocation);
            }
        }

        return result;
    }

    protected void handleConflict(skedModels.jobAllocation allocation, skedBaseModels.event event) {
        if (event.eventType == 'non-working') {
            allocation.conflictDetails = 'Non-Working time';
        }
        else {
            allocation.conflictDetails = 'Conflict with ' + event.name;
        }
    }

    protected integer getTravelTime(Location location1, Location location2) {
        integer travelTime = -1;
        if (location1 == NULL || location2 == NULL) {
            return travelTime;
        }

        if (location1.getLatitude() == location2.getLatitude() && location1.getLongitude() == location2.getLongitude()) {
            return 0;
        }

        double dist = location1.getDistance(location2, 'mi');

        integer velocity = 30;
        travelTime = ((dist / velocity) * 60).intValue();
        travelTime = travelTime < 1 ? 1 : travelTime;
        return travelTime;
    }

}