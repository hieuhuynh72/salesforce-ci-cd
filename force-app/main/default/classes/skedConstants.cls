public class skedConstants {
    public static final string ACCCOUNT_SCORE_BLACKLIST = 'Do not schedule';
    public static final string ACCCOUNT_SCORE_WHITELIST = 'Preferred';

    public static final string AVAILABILITY_STATUS_APPROVED = 'Approved';
    public static final string AVAILABILITY_STATUS_PENDING = 'Pending';
    public static final string AVAILABILITY_STATUS_DECLINED = 'Declined';

    public static final string JOB_CANCELLATION_REASON_RESCHEDULED = 'Rescheduled';

    public static final string JOB_STATUS_CANCELLED = 'Cancelled';
    public static final string JOB_STATUS_COMPLETE = 'Complete';
    public static final string JOB_STATUS_DISPATCHED = 'Dispatched';
    public static final string JOB_STATUS_IN_PROGRESS = 'In Progress';
    public static final string JOB_STATUS_PENDING_ALLOCATION = 'Pending Allocation';
    public static final string JOB_STATUS_PENDING_DISPATCH = 'Pending Dispatch';
    public static final string JOB_STATUS_QUEUED = 'Queued';
    public static final string JOB_STATUS_READY = 'Ready';
    public static final string JOB_STATUS_EN_ROUTE = 'En Route';
    public static final string JOB_STATUS_ON_SITE = 'On Site';

    public static final string JOB_ALLOCATION_STATUS_COMPLETE = 'Complete';
    public static final string JOB_ALLOCATION_STATUS_CONFIRMED = 'Confirmed';
    public static final string JOB_ALLOCATION_STATUS_EN_ROUTE = 'En Route';
    public static final string JOB_ALLOCATION_STATUS_CHECKED_IN = 'Checked In';
    public static final string JOB_ALLOCATION_STATUS_DECLINED = 'Declined';
    public static final string JOB_ALLOCATION_STATUS_DELETED = 'Deleted';
    public static final string JOB_ALLOCATION_STATUS_DISPATCHED = 'Dispatched';
    public static final string JOB_ALLOCATION_STATUS_PENDING_DISPATCH = 'Pending Dispatch';
    public static final string JOB_ALLOCATION_STATUS_IN_PROGRESS = 'In Progress';

    public static final string SERVICE_REQUEST_STATUS_CANCELLED = 'Cancelled';
    public static final string SERVICE_REQUEST_STATUS_DRAFT = 'Draft';
    public static final string SERVICE_REQUEST_STATUS_SUBMITTED = 'Submitted';
    public static final string SERVICE_REQUEST_STATUS_ASSIGNED = 'Assigned';
    public static final string SERVICE_REQUEST_STATUS_COMPLETED = 'Complete';

    public static final string RESOURCE_TYPE_PERSON = 'Person';
    public static final string RESOURCE_TYPE_ASSET = 'Asset';

    public static final string SERVICE_STATUS_OPEN = 'OHA';
    public static final string SERVICE_STATUS_DELIVERED = 'COM';
    public static final string SERVICE_STATUS_ASSIGNED = 'OPA';
    public static final string SERVICE_STATUS_CANCELLED = 'CAN';
    public static final string SERVICE_STATUS_DEFERRED = 'OHC';
    public static final string SERVICE_STATUS_PENDING_CREDIT = 'PCR';

    public static final string SKED_USER_TYPE_ADMIN = 'Administrator';
    public static final string SKED_USER_TYPE_SCHEDULER = 'Scheduler';
    public static final string SKED_USER_TYPE_RESOURCE = 'Resource';
    public static final string SKED_USER_TYPE_SALES_REP = 'Sales Rep';

    public static final string HOLIDAY_GLOBAL = 'global';

    public static final string JOB_CANCELLATION_SMS = 'Cancellation SMS';

    public static final string ADDRESS_TYPE_PHYSICAL_LOCATION = 'Physical Location';

    public static final string INVALID_ADDRESS_ERROR_MSG = 'Invalid address.';
    public static final string NO_REGION_ERROR_MSG = 'The address is not supported. Please contact the Admin to update the data.';
    public static final string NO_DRAFT_REGION_ERROR_MSG = 'No Skedulo Region found. Please contact the Admin to setup the data.';
    public static final string UNAVAILABLE_FOR_TRAVEL_DAYS = 'The Consultant is unavailable or has a conflict on one or more days selected. Please verify the assignments on the Availability Console.';

    //format day label on setter booking modal
    public static final string WEEKDAY_DAY_MONTH = 'EEE d MMM';
    public static final string WEEKDAY = 'EEE';
    public static final string WEEKDAY_DAY_MONTH_YEAR = 'EEEEE d MMM yyyy';
    public static final string HOUR_ONLY = 'ha';
    public static final String HOUR_MINUTES_ONLY = 'h:mma';
    public static final String YYYY_MM_DD = 'yyyy-MM-dd';
    public static final String MM_DD_YY_HH_MM = 'MM/dd/yy h:mma';
    public static final String MM_DD_YY_HH_MM_TIMEZONE = 'MM/dd/yy h:mma z';
    public static final String DATE_TIME_IN_QUERY = 'yyyy-MM-dd\'T\'hh:mm:ss\'Z\'';
    public static final String USER_NOT_ASSOCIATED_WITH_RES = 'The current login user is not associated with any resource';
    public static final String VIVINT_OPP_TYPE = 'Summer – New Sale';

    public static final String JOB_DUPLICATED_ADDRESS = 'Address exists on another appointment. Customer to call 855-823-0019 to reschedule.';
    public static final String JOB_DUPLICATED_PHONE = 'Phone number exists on another appointment. Customer to call 855-823-0019 to reschedule.';
    public static final String JOB_DUPLICATED_EMAIL = 'Email address exists on another appointment. Customer to call 855-823-0019 to reschedule.';
    public static final String SELECTED_SLOT_IS_NOT_AVAI = 'The selected slot is not available, please select another one';
    public static final string SELECTED_SLOT_IS_NOT_AVAI_AMQ = 'This slot is closed. Are you sure you want to book the appointment?';

    public static final string HOME_LEASE_UP = 'Lease up';
    public static final string HOME_STABILIZED = 'Stabilized';

    public static final string HTTPS_PREFIX = 'https://';
    public static final string HTTP_PREFIX = 'http://';


    // HTTP CODE
    public static final Integer HTTP_RESPONSE_OK = 200;
    public static final Integer HTTP_RESPONSE_CREATED = 201;
    public static final Integer HTTP_RESPONSE_NO_CONTENT = 204;
    public static final Integer HTTP_RESPONSE_BAD_REQUEST = 400;
    public static final Integer HTTP_RESPONSE_INTERNAL_ERROR = 500;

    // Project custom
    public static final String CANNOT_CANNCEL_JOB_ERROR_MSG = 'You cannot cancel a job with status In-progress, Complete or Cancelled.';
    public static final String SKED_JOB = 'sked__Job__c';
    public static final String SKED_JOB_ALLOCATION = 'sked__Job_Allocation__c';
    public static final String TOUR_CANCELLED_REASON_OTHER = 'Other';

    //Route status
    public static final string ROUTE_STATUS_PENDING_ALLOCATION = 'Pending Allocation';
    public static final string ROUTE_STATUS_PENDING_DISPATCH = 'Pending Dispatch';
    public static final string ROUTE_STATUS_DISPATCHED = 'Dispatched';
    public static final string ROUTE_STATUS_DELETED = 'Deleted';
}