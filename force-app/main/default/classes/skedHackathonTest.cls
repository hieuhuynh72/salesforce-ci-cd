@isTest
public with sharing class skedHackathonTest {
    @isTest
    public static void skedHackathonTest() {
        Test.startTest();
        skedHackathonController testService = new skedHackathonController();
        testService.Name = 'Test';
        Test.stopTest();
        // Commit 3
    }
}
