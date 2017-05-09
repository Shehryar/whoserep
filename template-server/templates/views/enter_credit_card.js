const CancelSubmitScrollView = require('./cancel_submit_scroll_view');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	const content = data.root.content;

	// Content
	data.root.scrollContent = new Components.Label({
		text: 'Hello, world'
	});

	CancelSubmitScrollView.call(this, data);
};
