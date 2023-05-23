@isTest
private class skedDateTimeUtils_Practice {
    @isTest
    static void practiceDateTimeUtils() {
        String vnTimezone = 'Asia/Saigon';
        String sydneyTimezone = 'Australia/Sydney';

        DateTime vn9am;
        DateTime sydney9am;
        DateTime sydneyStartOfDate;
        DateTime sydneyNextDate;

        // Change the code below this line

        // Initilize a new Date Time instance at 9am Oct 03, 2023, vn timezone by calling newDateTimeInstance()
        vn9am = null;

        // Calling switchTimezone() to set sydney9am to 9am Oct 03, 2023, sydney timezone from vn9am
        sydney9am = null;

        // Set time at 12:00 am, Oct 03, 2023, sydney timezone from sydney9am by calling getStartOfDate()
        sydneyStartOfDate = null;

        // Get time at 12:00 am, Oct 04, 2023, sydney timezone from sydneyStartOfDate by calling addDays()
        sydneyNextDate = null;

        // Change the code above this line

        // System.assertEquals('03/10/2023 09:00 AM', vn9am.format(skedDateTimeUtils.DATE_TIME_DMY_FORMAT, vnTimezone));
        // System.assertEquals('03/10/2023 09:00 AM', sydney9am.format(skedDateTimeUtils.DATE_TIME_DMY_FORMAT, sydneyTimezone));
        // System.assertEquals('03/10/2023 12:00 AM', sydneyStartOfDate.format(skedDateTimeUtils.DATE_TIME_DMY_FORMAT, sydneyTimezone));
        // System.assertEquals('04/10/2023 12:00 AM', sydneyNextDate.format(skedDateTimeUtils.DATE_TIME_DMY_FORMAT, sydneyTimezone));
    }
}