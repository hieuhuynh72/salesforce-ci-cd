@isTest
public with sharing class skedTestService_Test {
    @isTest
    public testSkedTestService() {
        Test.startTest();
        skedTestService testService = new skedTestService();
        Test.stopTest();
    }
}