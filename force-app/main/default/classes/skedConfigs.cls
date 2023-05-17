public class skedConfigs {
	private static skedConfigs__c configs;

    /**
    *@description Singleton to get Sked configs custom setting
    *
    */
    public static skedConfigs__c getSkedConfigsSettings() {
        if(configs == null) {
            configs = skedConfigs__c.getOrgDefaults();
        }
        return configs;
    }
}