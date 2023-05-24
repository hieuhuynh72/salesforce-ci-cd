@isTest
public with sharing class skedTestService_Test {
    @isTest
    public static void testSkedTestService() {
        //update
        Test.startTest();
        skedTestService testService = new skedTestService();
        Test.stopTest();
    }
}