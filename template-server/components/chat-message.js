// chat-message.js
// ===============

var ComponentViewAttachment = require('./component-view-attachment');

module.exports = {
	
	build: function(data) {
		var message = {};
		if (data.text) message.text = data.text;
		if (data.attachment) message.attachment = data.attachment;
		if (data.quickReplies) message.quickReplies = data.quickReplies;
		return message;
	}
}
