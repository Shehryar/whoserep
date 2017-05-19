// attachment.js

module.exports = function(data) {
	if (data.content) this.content = data.content;
	if (data.requiresNoContainer) this.requiresNoContainer = data.requiresNoContainer;
	if (data.quickReplies) this.quickReplies = data.quickReplies;
};
