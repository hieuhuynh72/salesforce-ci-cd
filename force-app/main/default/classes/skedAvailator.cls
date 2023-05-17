public class skedAvailator extends skedAvailatorBase {

    public skedAvailator(skedAvailatorParams inputParams) {
        super(inputParams);
    }

    public List<skedModels.DateModel> getBookingDate() {
        List<skedModels.DateModel> bkDates = new List<skedModels.DateModel>();
        Map<String, skedModels.DateModel> mpBkDates = new Map<String, skedModels.DateModel>();

        String dateFormat;
        Date dateValue;
        skedModels.DateModel dateModel;
        Set<Date> allHolidays = getAllHolidays();
        skedModels.TimeSlotModel timeSlot;

        DateTime firstJobStart, lastJobFinish;
        getStartFinishTime(firstJobStart, lastJobFinish);

        for (skedModels.job job : params.inputJobs) {
            job.noOfQualifiedResources = 0;
            job.noOfAvailableResources = 0;
            dateFormat = job.start.format(skedDateTimeUtils.DATE_ISO_FORMAT, params.timezoneSidId);
            dateValue = (Date)Json.deserialize(job.start.format(skedDateTimeUtils.DATE_ISO_FORMAT, params.timezoneSidId), Date.class);

            List<string> requiredTagIds = new List<string>();
            if (job.tags != NULL && !job.tags.isEmpty()) {
                for (skedBaseModels.tag jobTag : job.tags) {
                    requiredTagIds.add(jobTag.id);
                }
            }

            if (!mpBkDates.containsKey(dateFormat)) {
                dateModel = new skedModels.DateModel();

                dateModel.dateISO = dateFormat;
                dateModel.dayOfWeek = job.start.format(skedDateTimeUtils.DATE_OF_WEEK_FORMAT, params.timezoneSidId).toUpperCase();

                if (allHolidays.contains(dateValue)) {
                    dateModel.isHoliday = true;
                }
                mpBkDates.put(dateFormat, dateModel);
                bkDates.add(dateModel);
            } else {
                dateModel = mpBkDates.get(dateFormat);
            }

            timeSlot = new skedModels.TimeSlotModel();
            timeSlot.startTime = skedDateTimeUtils.getTimeNumber(job.start, params.timezoneSidId);
            timeSlot.endTime = skedDateTimeUtils.getTimeNumber(job.finish, params.timezoneSidId);
            timeSlot.dateISO = dateModel.dateISO;

            dateModel.timeSlots.add(timeSlot);

            for (skedResourceAvailabilityBase.resourceModel resource : this.mapResource.values()) {
                skedModels.jobAllocation allocation = new skedModels.jobAllocation();
                allocation.resource = resource;
                allocation.resourceId = resource.id;
                allocation.job = job;
                allocation.jobId = job.id;

                if (requiredTagIds.size() > 0) {
                    Set<string> resourceTagIds = new Set<string>();
                    for (skedBaseModels.tag resourceTag : resource.tags) {
                        if (resourceTag.expiryTime == NULL || job.finish <= resourceTag.expiryTime) {
                            resourceTagIds.add(resourceTag.id);
                        }
                    }
                    allocation.isQualified = resourceTagIds.containsAll(requiredTagIds);
                    if (allocation.isQualified == false) {
                        continue;
                    }
                }

                validateAllocationWithTravelTime(allocation, resource, params.excludedJobIds);

                if (allocation.isQualified) {
                    job.noOfQualifiedResources++;
                    if (allocation.isAvailable) {
                        job.noOfAvailableResources++;
                        if (params.includeResourceInfo) {
                            timeSlot.availableResources.add(allocation);
                        }
                    }
                }
            }

            timeSlot.numOfAvailableResources = job.noOfAvailableResources;
            timeSlot.totalResources = job.noOfQualifiedResources;
        }
        return bkDates;
    }

    private Set<Date> getAllHolidays() {
        Map<string, Set<Date>> mapHolidays = skedUtils.getMapHolidays();

        Set<Date> allHolidays = new Set<Date>();
        // Global holidays
        if (mapHolidays.containsKey(skedConstants.HOLIDAY_GLOBAL)) {
            Set<Date> globalHolidays = mapHolidays.get(skedConstants.HOLIDAY_GLOBAL);
            allHolidays.addAll(globalHolidays);
        }

        // Holidays in regions
        for (Id regionId : params.regionIds) {
            if (mapHolidays.containsKey(regionId)) {
                allHolidays.addAll(mapHolidays.get(regionId));
            }
        }
        return allHolidays;
    }

    private void getStartFinishTime(DateTime firstJobStart, DateTime lastJobFinish) {
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
    }
}