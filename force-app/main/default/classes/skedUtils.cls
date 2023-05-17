public class skedUtils {
    private static Map<string, Set<Date>> mpHolidaysInstance;


    /**
    *@description Singleton to get mpHolidays
    *
    */
    public static Map<string, Set<Date>> getMapHolidays() {
        if(mpHolidaysInstance == null) {
            mpHolidaysInstance = getHolidays();
        }
        return mpHolidaysInstance;
    }

    public static List<skedModels.selectOption> getPickListValues(string objectApiName, string fieldApiName) {
        List<string> picklistValues = new List<string>();

        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApiName);
        DescribeSObjectResult objDescribe = targetType.getDescribe();
        map<String, SObjectField> mapFields = objDescribe.fields.getmap();
        SObjectField fieldType = mapFields.get(fieldApiName);
        DescribeFieldResult fieldResult = fieldType.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple) {
            picklistValues.add(f.getValue());
        }

        List<skedModels.selectOption> result = new List<skedModels.selectOption>();
        for (string picklistValue : picklistValues) {
            result.add(new skedModels.selectOption(picklistValue, picklistValue));
        }
        return result;
    }

    public static Map<string, Set<Date>> getHolidays() {
        Map<string, Set<Date>> mapHolidays = new Map<string, Set<Date>>();
        Date currentDate = system.now().date().addDays(-1);//buffer for different timezone

        List<sked__Holiday__c> skedGlobalHolidays = [SELECT Id, sked__Start_Date__c, sked__End_Date__c
                                                     FROM sked__Holiday__c
                                                     WHERE sked__Global__c = TRUE
                                                     AND sked__End_Date__c >= :currentDate];
        List<sked__Holiday_Region__c> skedRegionHolidays = [SELECT Id, sked__Holiday__r.sked__Start_Date__c, sked__Holiday__r.sked__End_Date__c,
                                                            sked__Region__c
                                                            FROM sked__Holiday_Region__c
                                                            WHERE sked__Holiday__r.sked__End_Date__c >= :currentDate];

        Set<Date> globalHolidays = new Set<Date>();
        for (sked__Holiday__c globalHoliday : skedGlobalHolidays) {
            Date tempDate = globalHoliday.sked__Start_Date__c;
            while (tempDate <= globalHoliday.sked__End_Date__c) {
                globalHolidays.add(tempDate);
                tempDate = tempDate.addDays(1);
            }
        }
        mapHolidays.put(skedConstants.HOLIDAY_GLOBAL, globalHolidays);

        for (sked__Holiday_Region__c regionHoliday : skedRegionHolidays) {
            Set<Date> regionHolidays;
            if (mapHolidays.containsKey(regionHoliday.sked__Region__c)) {
                regionHolidays = mapHolidays.get(regionHoliday.sked__Region__c);
            } else {
                regionHolidays = new Set<Date>();
            }

            Date tempDate = regionHoliday.sked__Holiday__r.sked__Start_Date__c;
            while (tempDate <= regionHoliday.sked__Holiday__r.sked__End_Date__c) {
                regionHolidays.add(tempDate);
                tempDate = tempDate.addDays(1);
            }

            if (!mapHolidays.containsKey(regionHoliday.sked__Region__c)) {
                mapHolidays.put(regionHoliday.sked__Region__c, regionHolidays);
            }
        }
        return mapHolidays;
    }

    public static Map<string, Set<skedModels.selectOption>> getHolidayOptions() {
        Map<string, Set<skedModels.selectOption>> mapHolidays = new Map<string, Set<skedModels.selectOption>>();
        Date currentDate = system.now().date().addDays(-1);//buffer for different timezone

        List<sked__Holiday__c> skedGlobalHolidays = [SELECT Id, Name, sked__Start_Date__c, sked__End_Date__c
                                                     FROM sked__Holiday__c
                                                     WHERE sked__Global__c = TRUE
                                                     AND sked__End_Date__c >= :currentDate];
        List<sked__Holiday_Region__c> skedRegionHolidays = [SELECT Id, sked__Holiday__r.Name, sked__Holiday__r.sked__Start_Date__c, sked__Holiday__r.sked__End_Date__c,
                                                            sked__Region__c
                                                            FROM sked__Holiday_Region__c
                                                            WHERE sked__Holiday__r.sked__End_Date__c >= :currentDate];

        Set<skedModels.selectOption> globalHolidays = new Set<skedModels.selectOption>();
        for (sked__Holiday__c globalHoliday : skedGlobalHolidays) {
            Date tempDate = globalHoliday.sked__Start_Date__c;
            while (tempDate <= globalHoliday.sked__End_Date__c) {
                string dateIso = Json.serialize(tempDate).replace('"', '');
                skedModels.selectOption holidayOption = new skedModels.selectOption(dateIso, globalHoliday.Name);
                globalHolidays.add(holidayOption);
                tempDate = tempDate.addDays(1);
            }
        }
        mapHolidays.put(skedConstants.HOLIDAY_GLOBAL, globalHolidays);

        for (sked__Holiday_Region__c regionHoliday : skedRegionHolidays) {
            Set<skedModels.selectOption> regionHolidays;
            if (mapHolidays.containsKey(regionHoliday.sked__Region__c)) {
                regionHolidays = mapHolidays.get(regionHoliday.sked__Region__c);
            } else {
                regionHolidays = new Set<skedModels.selectOption>();
            }

            Date tempDate = regionHoliday.sked__Holiday__r.sked__Start_Date__c;
            while (tempDate <= regionHoliday.sked__Holiday__r.sked__End_Date__c) {
                string dateIso = Json.serialize(tempDate).replace('"', '');
                skedModels.selectOption regionHolidayOption = new skedModels.selectOption(dateIso, regionHoliday.sked__Holiday__r.Name);
                regionHolidays.add(regionHolidayOption);
                tempDate = tempDate.addDays(1);
            }

            if (!mapHolidays.containsKey(regionHoliday.sked__Region__c)) {
                mapHolidays.put(regionHoliday.sked__Region__c, regionHolidays);
            }
        }
        return mapHolidays;
    }

    /*
        * seach object by name.
        * search by 'term%', if no records found then query by '%term%'.
    */
    public static skedResponse searchByName(String term, string objectName){
        skedResponse response = new skedResponse();
        list<skedBaseModels.ObjectModel> result = new list<skedBaseModels.ObjectModel>();
        string searchTerm = '' + term + '%';
        //string searchTerm2 = '%' + term + '%';
        string searchQuery = 'select id, name from ' + objectName +' where name like:searchTerm Order By Name limit 100';

        try{
            List<sObject> sobjList = Database.query(searchQuery);
            //if search 'term%' not found, then search by '%term%'.
            if(sobjList.isEmpty()){
                searchTerm = '%' + term + '%';
                sobjList = Database.query(searchQuery);
            }
            for(sObject obj:sobjList){
                result.add(new skedBaseModels.ObjectModel(obj));
            }
            response.data = result;
            response.success = true;
        } catch(Exception ex){
            response.getErrorMessage(ex);
        }
        return response;
    }

    public static Boolean canCancelJob(String jobStatus) {
        return !(
            skedConstants.JOB_STATUS_IN_PROGRESS.equalsIgnoreCase(jobStatus) || skedConstants.JOB_STATUS_COMPLETE.equalsIgnoreCase(jobStatus)
            || skedConstants.JOB_STATUS_CANCELLED.equalsIgnoreCase(jobStatus)
        );
    }

    public static String buildLikeSearchString(String term) {
        if (String.isBlank(term)) {
            return '%%';
        }

        return '%' + String.escapeSingleQuotes(term).trim() + '%';
    }

}