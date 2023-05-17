public class skedLightningService {

    @AuraEnabled
    public static String getJobInfo(String jobId) {
        List<sked__Job__c> jobs = [
            SELECT Id, Name, sked__Job_Status__c
            FROM sked__Job__c
            WHERE Id = :jobId
        ];

        JobInfoModel jobInfo;

        if (jobs.isEmpty()) {
            jobInfo = new JobInfoModel();
        } else {
            jobInfo = new JobInfoModel(jobs[0]);
        }
        return JSON.serialize(jobInfo);
    }

    public class JobInfoModel {
        public String jobId;
        public String jobStatus;
        public Boolean tourIsCancelled;

        public JobInfoModel() {
            this.jobStatus = '';
        }

        public JobInfoModel(sked__Job__c skedJob) {
            this.jobId = skedJob.Id;
            this.jobStatus = skedJob.sked__Job_Status__c;
        }
    }
}