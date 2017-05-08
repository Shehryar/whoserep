const CancelSubmitScrollView = require('./cancel_submit_scroll_view');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.body = data.body || {};
	const content = data.body.content;

	// Content
	data.body.content = new Components.Label({
		text: 'Hello, world'
	});

	CancelSubmitScrollView.call(this, data);
};
