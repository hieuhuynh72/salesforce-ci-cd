global class skedBatchProcessor implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global String params;
    global String objectType;
    
    global skedBatchProcessor(String params, String objectType) {
        this.params     = params;
        this.objectType = objectType;
    }
    
    global List<sObject> start(Database.BatchableContext BC) {        
        String[] recordIds = params.split(';');
        String query = 'Select Id, ' + skedLocationServices.ADDR_FIELD_MAP.get(objectType)  + '  from ' + objectType + ' where Id IN :recordIds';
        return Database.query(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        list<String> idList = new list<String>();
        for(sObject o : scope){
            idList.add(o.Id);
        }
        skedLocationServices.updateGeoLocation(idList, objectType);
    }
    
    global void finish(Database.BatchableContext BC) {

    } 
}