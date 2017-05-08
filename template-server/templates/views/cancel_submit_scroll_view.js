const ComponentView = require('./component_view');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.body = data.body || {};
	const cancelButtonTitle = data.body.cancelButtonTitle || 'CANCEL';
	const cancelButtonAction = data.body.cancelButtonAction || {
		type: 'finish'
	};
	const submitButtonTitle = data.body.submitButtonTitle;
	const submitButtonAction = data.body.submitButtonAction;
	let scrollViewContent = data.body.content || {};

	// Content
	let scrollView = new Components.ScrollView({
		content: scrollViewContent,
		style: {
			weight: 1,
			gravity: 'fill'
		}
	});

	let buttonItems = [];
	if (cancelButtonTitle && cancelButtonAction) {
		buttonItems.push(new Components.Button({
			title: cancelButtonTitle,
			action: cancelButtonAction,
			buttonStyle: 'secondary',
			style: {
				weight: 1, 
				align: 'fill',
				gravity: 'fill'
			}
		}));		
	}
	if (submitButtonTitle && submitButtonAction) {
		buttonItems.push(new Components.Button({
			title: submitButtonTitle,
			action: submitButtonAction,
			buttonStyle: 'primary',
			style: {
				weight: 1, 
				align: 'fill',
				gravity: 'fill'
			}
		}));		
	}
	let buttonItemsContainer = new Components.StackView({
		orientation: 'horizontal',
		items: buttonItems,
		style: {
			weight: 0
		}
	});

	data.body = new Components.StackView({
		items: [
			scrollView,
			buttonItemsContainer
		],
		style: {
			gravity: 'fill'
		}
	});

	ComponentView.call(this, data);
};
