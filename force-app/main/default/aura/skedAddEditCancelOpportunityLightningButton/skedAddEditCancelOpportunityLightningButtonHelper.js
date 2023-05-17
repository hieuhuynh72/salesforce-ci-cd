({
  showModal: function(component, helper) {
		console.log('showModal 111');
		var nodes1 = document.querySelectorAll('.skedEditOpportunityModal');
		var nodes2 = document.querySelectorAll('.skedEditOpportunityModalBackdrop');
		for (var i = 0; i < nodes1.length; i++) {
			nodes1[i].classList.add('slds-fade-in-open');
		}
		for (var j = 0; j < nodes2.length; j++) {
			nodes2[j].classList.add('slds-backdrop--open');
		}
  },
  hideModal: function(component, helper) {
		console.log('hideModal 111 111');
		var nodes1 = document.querySelectorAll('.skedEditOpportunityModal');
		var nodes2 = document.querySelectorAll('.skedEditOpportunityModalBackdrop');
		for (var i = 0; i < nodes1.length; i++) {
			nodes1[i].classList.remove('slds-fade-in-open');
		}
		for (var j = 0; j < nodes2.length; j++) {
			nodes2[j].classList.remove('slds-backdrop--open');
		}
	},
	showButton: function (component, helper) {
		console.log('showButton');
		var nodes1 = document.querySelectorAll('.skedAddOpportunityButton');
		console.log('nodes1', nodes1);
		if (nodes1 && nodes1.length > 0) {
			for (var i = 0; i < nodes1.length; i++) {
				nodes1[i].classList.remove('slds-hide');
			}
		}
	},
  showModal2: function(component, helper) {
		console.log('showModal 111');
		var nodes1 = document.querySelectorAll('.skedEditOpportunityModal');
		var nodes2 = document.querySelectorAll('.skedEditOpportunityModalBackdrop');
		for (var i = 0; i < nodes1.length; i++) {
			nodes1[i].classList.add('slds-fade-in-open');
		}
		for (var j = 0; j < nodes2.length; j++) {
			nodes2[j].classList.add('slds-backdrop--open');
		}
  },
  hideModal2: function(component, helper) {
		console.log('hideModal 111 111');
		var nodes1 = document.querySelectorAll('.skedEditOpportunityModal');
		var nodes2 = document.querySelectorAll('.skedEditOpportunityModalBackdrop');
		for (var i = 0; i < nodes1.length; i++) {
			nodes1[i].classList.remove('slds-fade-in-open');
		}
		for (var j = 0; j < nodes2.length; j++) {
			nodes2[j].classList.remove('slds-backdrop--open');
		}
	},
	showButton2: function (component, helper) {
		console.log('showButton');
		var nodes1 = document.querySelectorAll('.skedEditCancelOpportunityButton');
		console.log('nodes1', nodes1);
		if (nodes1 && nodes1.length > 0) {
			for (var i = 0; i < nodes1.length; i++) {
				nodes1[i].classList.remove('slds-hide');
			}
		}
	},
  receiveMessage: function(component, helper, event) {
		console.log('receiveMessage edit opportunity', event, event.data, event.data.message);
		var data = event.data;
		if (data !== null && typeof data === 'object') {
      console.log('eventName edit opportunity', data.eventName);
      if (data.message && data.message === 'cancel') {
        console.log('hideModal edit opportunity');
        helper.hideModal(component, helper);
        helper.hideModal2(component, helper);
      } else if (data.message && data.message === 'done') {
        console.log('hideModal edit opportunity');
				helper.hideModal(component, helper);
				helper.hideModal2(component, helper);
				window.location.reload();
      }
		}
  }
})