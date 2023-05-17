({
	doInit: function(component, event, helper) {
    var recordId = component.get('v.recordId');
		console.log('doInit edit opportunity', recordId);
		window.addEventListener('message', helper.receiveMessage.bind(null, component, helper));
		// console.log('getJobInfo for opportunity', recordId);
		// var getJobDetailAction = component.get('c.getJobInfoFromOpportunityId');
		// getJobDetailAction.setParams({tourId: recordId});
		// getJobDetailAction.setCallback(this, function (response) {
		// 	console.log('getJobInfo result', response);
		// 	var state = response.getState();
		// 	if (state === "SUCCESS") {
		// 		console.log('return value', response.getReturnValue());
		// 		var job = JSON.parse(response.getReturnValue());
		// 		if (job.data) {
		// 			job = job.data;
		// 		}
		// 		if (!(job && (job.tourIsCancelled || job.jobStatus === 'Cancelled' || job.jobStatus === 'Complete'))) {
		// 			window['jobIdForOpportunity_' + recordId] = job.jobId;
		// 			window['jobStatusForOpportunity_' + recordId] = job.jobStatus;
		// 			setTimeout(function () {
		// 				console.log('jobId', window['jobIdForOpportunity_' + recordId]);
		// 				helper.showButton(component, helper);
		// 			}, 1000);
		// 		}
		// 		if (!(job && (job.tourIsCancelled || job.jobStatus === 'Cancelled' || job.jobStatus === 'Complete' || job.jobStatus === 'In Progress'))) {
		// 			window['jobIdForOpportunity_' + recordId] = job.jobId;
		// 			window['jobStatusForOpportunity_' + recordId] = job.jobStatus;
		// 			setTimeout(function () {
		// 				console.log('jobId', window['jobIdForOpportunity_' + recordId]);
		// 				helper.showButton(component, helper);
		// 			}, 1000);
		// 		}
		// 	}
		// });
		// $A.enqueueAction(getJobDetailAction);
	},
	closeModal:function(component, event, helper){
		console.log('closeModal edit opportunity');
		helper.hideModal(component, helper);
	},
	openModal: function(component, event, helper) {
		console.log('openModal edit opportunity');
		var recordId = component.get('v.recordId');
        var recordParam = '';
        
        if (recordId.startsWith('001')) {
            recordParam = 'accountId';
        } else {
            recordParam = 'opportunityId';
        }
        
		var ifmsrc = '/apex/skedCommonBookingGrid?'+recordParam+'=' + recordId + '&_t=' + Date.now();
		
		console.log('ifmsrc edit opportunity', ifmsrc);
		component.set('v.ifmsrc', ifmsrc);
		
		helper.showModal(component, helper);
	},
	closeModal2:function(component, event, helper){
		console.log('closeModal cancel opportunity');
		helper.hideModal2(component, helper);
	},
	openModal2: function(component, event, helper) {
		console.log('openModal cancel opportunity');
		
		var recordId = component.get('v.recordId');
        
        var recordParam = '';
        
        if (recordId.startsWith('001')) {
            recordParam = 'accountId';
        } else {
            recordParam = 'opportunityId';
        }
        
		var ifmsrc = '/apex/skedEventList?'+recordParam+'=' + recordId + '&_t=' + Date.now();
		
		console.log('ifmsrc edit opportunity', ifmsrc);
		component.set('v.ifmsrc', ifmsrc);
		
		helper.showModal2(component, helper);
	},
})