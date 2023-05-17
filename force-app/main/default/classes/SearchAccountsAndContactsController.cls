public class SearchAccountsAndContactsController {
    public String searchKeyInput {get;set;}
    public List<ResultWrapper> results {get; set;}

    public class ResultWrapper {
        public String id {get;set;}
        public String name {get;set;}
        public String type {get;set;}
        public String link {get;set;}
        public Decimal counter {get; set;}
 
        public ResultWrapper(SObject record, String type) {
            this.id = (String) record.get('Id');
            this.name = (String) record.get('Name');
            this.type = type;
            this.link = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String) record.get('Id');
            this.counter = (Decimal) record.get('Counter__c') != NULL ? (Decimal) record.get('Counter__c') : 0;
        }
    }

    public void search() {
        this.results = new List<ResultWrapper>();

        List<Account> accounts = [SELECT Id, Name, Counter__c FROM Account WHERE Name LIKE :(searchKeyInput + '%')];
        List<Contact> contacts = [SELECT Id, Name, Counter__c FROM Contact WHERE Name LIKE :(searchKeyInput + '%')];

        if (accounts.size() > 0) {
            for (Account account : accounts) {
                results.add(new ResultWrapper(account, SObjectType.Account.getLabel()));
            }
        }

        if (contacts.size() > 0) {
            for (Contact contact : contacts) {
                results.add(new ResultWrapper(contact, SObjectType.Contact.getLabel()));
            }
        }
    }

    @RemoteAction
    public static Decimal updateCounter(Id recordId) {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        Decimal result = 0;
        Decimal counter;

        if (sObjName == SObjectType.Account.getLabel()) {
            Account account = [Select Id, Counter__c from Account where Id = :recordId];
            counter = account.Counter__c == NULL ? 0 : account.Counter__c;
            account.Counter__c = counter + 1;

            update account;
            result = account.Counter__c;
        }

        if (sObjName == SObjectType.Contact.getLabel()) {
            Contact contact = [Select Id, Counter__c from Contact where Id = :recordId];
            counter = contact.Counter__c == NULL ? 0 : contact.Counter__c;
            contact.Counter__c = counter + 1;
            System.debug(contact.Counter__c);

            update contact;
            result = contact.Counter__c;
        }

        return result;
    }
}