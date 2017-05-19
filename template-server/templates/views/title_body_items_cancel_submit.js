const CancelSubmitScrollView = require('./cancel_submit_scroll_view');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	const scrollContentData = data && data.root ? data.root.scrollContent || {} : {};
	const title = scrollContentData.title;
	const bodyText = scrollContentData.bodyText;
	const items = scrollContentData.items;
	
	let stackViewItems = [];
	if (title) {
		stackViewItems.push(new Components.Label({
			text: title,
			style: {
				textType: 'header2',
				marginBottom: bodyText || items ? 16 : 0
			}
		}));
	}
	if (bodyText) {
		stackViewItems.push(new Components.Label({
			text: bodyText,
			style: {
				textType: 'body',
				marginBottom: items ? 24 : 0
			}
		}));
	}
	if (items) {
		stackViewItems = stackViewItems.concat(items);
	}
	
	data.root.scrollContent = new Components.StackView({
		items: stackViewItems,
		style: {
			padding: '36 24'
		}
	});

	CancelSubmitScrollView.call(this, data);
};
