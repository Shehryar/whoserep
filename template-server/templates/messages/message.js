// message.js

const QuickReply = require('./quick_reply');

module.exports = function(data, attachment) {
	if (data.text) this.text = data.text;
	if (attachment) this.attachment = attachment;
	if (data.metadata) this.metadata = data.metadata;

	if (data.quickReplies && data.quickReplies.length > 0) {
		this.quickReplies = [];
		for (var i = 0; i < data.quickReplies.length; i++) {
			const quickReplyData = data.quickReplies[i];
			this.quickReplies.push(new QuickReply(quickReplyData));
		}
	}
};
