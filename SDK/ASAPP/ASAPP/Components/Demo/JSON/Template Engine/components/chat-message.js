// chat-message.js
// ===============

module.exports = {
	
	build: function(data) {
		var message = {};
		if (data.text) message.text = data.text;
		if (data.attachment) message.attachment = data.attachment;
		if (data.quickReplies) message.quickReplies = data.quickReplies;
		return message;
	}
}