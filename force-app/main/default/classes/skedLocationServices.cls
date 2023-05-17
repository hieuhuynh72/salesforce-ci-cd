global class skedLocationServices{

    public static final String OBJ_LOCATION     = 'sked__Location__c';
    public static final String OBJ_JOB          = 'sked__Job__c';
    public static final String OBJ_RESOURCE     = 'sked__Resource__c';
    public static final String OBJ_ACTIVITY     = 'sked__Activity__c';
    public static final String OBJ_ACCOUNT      = 'Account';
    public static final String GOO_END_POINT    = 'https://maps.googleapis.com/maps/api';

    public static final Decimal M_TO_MILES = 0.000621371;

    public static Integer BATCH_SIZE            = 50;

    public static string LAT_FIELD  = 'sked__GeoLocation__latitude__s';
    public static string LONG_FIELD = 'sked__GeoLocation__longitude__s';

    public static String API_KEY{
        get{
            if(API_KEY == null){
                skedConfigs__c configs = skedConfigs.getSkedConfigsSettings();
                if (configs != null) {
                    API_KEY = configs.Google_Maps_API_Key__c;
                } else {
                    API_KEY = null;
                }
            }
            return API_KEY;
        }
    }

    public static String DEFAULT_SEARCH_COUNTRY {
        get{
            if(DEFAULT_SEARCH_COUNTRY == null){
                skedConfigs__c configs = skedConfigs.getSkedConfigsSettings();
                if (configs != null) {
                    DEFAULT_SEARCH_COUNTRY = configs.Country_Code__c;
                } else {
                    DEFAULT_SEARCH_COUNTRY = null;
                }
            }
            return DEFAULT_SEARCH_COUNTRY;
        }
    }

    public static Map<String,String> ADDR_FIELD_MAP = new Map<String,String>{
        OBJ_LOCATION    => 'sked__Address__c',
        OBJ_JOB         => 'sked__Address__c',
        OBJ_RESOURCE    => 'sked__Home_Address__c',
        OBJ_ACTIVITY    => 'sked__Location__c',
        OBJ_ACCOUNT     => 'Physical_Address__c'
    };

    /*
    * Populate Location Geocode when address is changed
    */
    public static void updateLocationGeocode(list<sObject> oldList, Map<Id, sObject> newMap, String objectType){

        if(System.isFuture()) return;
        if(!ADDR_FIELD_MAP.containsKey(objectType)) return;

        Set<Id> locationIDs = new Set<Id>();
        String addressField = ADDR_FIELD_MAP.get(objectType);
        if(oldList == null){//Insert
            locationIDs = newMap.keySet();
        }else{//Update
            sObject newLoc;
            for(sObject oldLoc : oldList){
                newLoc = newMap.get(oldLoc.Id);
                if(objectType == OBJ_ACCOUNT) LAT_FIELD = 'Physical_GeoLocation__latitude__s';
                if(objectType == OBJ_RESOURCE) LAT_FIELD = 'sked__GeoLocation__latitude__s';
                if(newLoc.get(addressField) != null){
                    if(newLoc.get(LAT_FIELD) == null){
                        locationIDs.add(newLoc.Id);
                    } else {
                        if(newLoc.get(addressField) != oldLoc.get(addressField)){
                            locationIDs.add(newLoc.Id);
                        }
                    }
                }
            }
        }
        if(locationIDs==null || locationIDs.isEmpty()) return;
        list<Id> idList = new list<Id>(locationIDs);
        if(idList.size() > BATCH_SIZE){//Process in batch to avoid callout limit
            skedBatchProcessor batch = new skedBatchProcessor(String.join(idList,';'), objectType);
            Database.executeBatch(batch, BATCH_SIZE);
        }else updateGeoLocationAsync(String.join(idList,';'), objectType);

    }

    /*
    * Update geolocation for a list of record
    */
    global static void updateGeoLocation(list<String> recordIds, string objectType) {
        if(!ADDR_FIELD_MAP.containsKey(objectType)) return;

        String query = 'Select Id, ' + ADDR_FIELD_MAP.get(objectType)  + '  from ' + objectType + ' where Id IN :recordIds';

         List<sObject> records = Database.query(query);
        String addressField = ADDR_FIELD_MAP.get(objectType);
        for (sObject record : records) {

            Location geoData = getAddressGeoLocation( (String)record.get(addressField) );
            system.debug(geoData);
            if (geoData != null) {
                if(objectType == 'Account'){
                    LAT_FIELD  = 'Physical_GeoLocation__latitude__s';
                    LONG_FIELD = 'Physical_GeoLocation__longitude__s';
                }
                if(objectType == 'sked__Resource__c'){
                    LAT_FIELD  = 'sked__GeoLocation__latitude__s';
                    LONG_FIELD = 'sked__GeoLocation__longitude__s';
                }
                record.put(LAT_FIELD, geoData.getLatitude());
                record.put(LONG_FIELD, geoData.getLongitude());

            }
        }
        update records;
    }

     /*
    * Asynchronously update geolocation for a list of record
    */
    @future(callout=true)
    global static void updateGeoLocationAsync(String idList, string objectType) {
        if(!System.isFuture() || System.isBatch()) return;//cannot call a future method from a future or batch context
        string[] recordIds = idList.split(';');
        updateGeoLocation(recordIds, objectType);
    }


    @future(callout=true)
    global static void updateGeoLocation(String idList, string objectType) {
        if(!ADDR_FIELD_MAP.containsKey(objectType)) return;
        string[] recordIds = idList.split(';');

        String query = 'Select Id, ' + ADDR_FIELD_MAP.get(objectType)  + '  from ' + objectType + ' where Id IN :recordIds';

         List<sObject> records = Database.query(query);
        String addressField = ADDR_FIELD_MAP.get(objectType);
        for (sObject record : records) {
            system.debug('addressField::' + (String)record.get(addressField) );
            Location geoData = getAddressGeoLocation( (String)record.get(addressField) );
            system.debug('geoData::' + geoData);

            if (geoData != null) {
                if(objectType == 'Account'){
                    LAT_FIELD  = 'Physical_GeoLocation__latitude__s';
                    LONG_FIELD = 'Physical_GeoLocation__longitude__s';
                }
                if(objectType == 'sked__Resource__c'){
                    LAT_FIELD  = 'sked__GeoLocation__latitude__s';
                    LONG_FIELD = 'sked__GeoLocation__longitude__s';
                }
                record.put(LAT_FIELD, geoData.getLatitude());
                record.put(LONG_FIELD, geoData.getLongitude());
            }

        }

        system.debug('sked::updateGeoLocation future::' + records );
        update records;
    }

    global class AutoCompleteAddress {
        global List<Prediction> predictions {get;set;}
        global string status { get; set; }
    }

    global class Prediction {
        global String description {get;set;}
        global String place_id {get;set;}
    }

    global class PlaceDetails {
        global PlaceResult result {get;set;}
        global string status {get;set;}
    }

    global class PlaceResult {
        global List<AddressComponent> address_components;
    }

    global class AddressComponent {
        global String long_name;
        global String short_name;
        global List<String> types;
    }

    /*get GeoLocation from Google API*/
    global static Location getAddressGeoLocation(string address){
        if (String.isBlank(address)) {
            return null;
        }

        address = EncodingUtil.urlEncode(address, 'UTF-8');
        // build callout
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        STRING endPointString = GOO_END_POINT + '/geocode/json?address='+address+'&key=' + API_KEY;
        System.debug(' endPointString ====' + endPointString );

        req.setEndpoint(endPointString);
        req.setMethod('GET');
        req.setTimeout(10000);

        System.debug(' address ====' + address );

        try{
            // callout
            HttpResponse res = h.send(req);
            System.debug('Skedulo Response ===' + res.getBody());
            // parse coordinates from response
            JSONParser parser = JSON.createParser(res.getBody());
            double lat = null;
            double lon = null;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'location')){
                        parser.nextToken(); // object start
                        while (parser.nextToken() != JSONToken.END_OBJECT){
                            String txt = parser.getText();
                            parser.nextToken();
                            if (txt == 'lat')
                                lat = parser.getDoubleValue();
                            else if (txt == 'lng')
                                lon = parser.getDoubleValue();
                        }

                    }
            }
            Location obj =  Location.newInstance(lat,lon);
            return obj;

        } catch (Exception e) {
        }
        return null;
    }

    global static AutoCompleteAddress getAddresses(String searchingText) {
        searchingText = EncodingUtil.urlEncode(searchingText, 'UTF-8');

        String country = DEFAULT_SEARCH_COUNTRY;

        Http http           = new Http();
        HttpRequest req     = new HttpRequest();
        HttpResponse res    = new HttpResponse();

        string EndPoint = GOO_END_POINT + '/place/autocomplete/json?input=' + searchingText + '&language=en-US&key=' + API_KEY;

        if (String.isNotBlank(country)) {
            EndPoint += '&components=country:' + country;
        }

        system.debug('nam EndPoint: ' + EndPoint);
        req.setEndpoint( EndPoint );
        req.setMethod('GET');
        req.setTimeout(10000);

        system.debug('=== EndPoint: ' + EndPoint);

        integer responseCode = 0;
        string jsonResponse = '';

        res = http.send(req);
        responseCode = res.getStatusCode();
        system.debug('===res: ' + res);
        if(responseCode == 200){
            try{
                jsonResponse = res.getBody();
                system.debug('=== jsonResponse: ' + jsonResponse);

                AutoCompleteAddress result = (AutoCompleteAddress)JSON.deserialize(jsonResponse, AutoCompleteAddress.class);
                if (result.status == 'OK') {
                    return result;
                }
            } catch(Exception ex){
                system.debug('exception=' + ex);
            }
        }
        return null;
    }


}