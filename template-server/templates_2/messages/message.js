// message.js

module.exports = function(data, attachment) {
	if (data.text) this.text = data.text;
	if (attachment) this.attachment = attachment;
	if (data.quickReplies) this.quickReplies = data.quickReplies;
	if (data.metadata) this.metadata = data.metadata;
};
