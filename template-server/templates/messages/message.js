// message.js

const QuickReply = require('./quick_reply');

module.exports = function(data, attachment) {
	if (data.text) this.text = data.text;
	if (attachment) this.attachment = attachment;
	if (data.metadata) this.metadata = data.metadata;
	if (data.quickReplies) {
		this.quickReplies = parseQuickReplies(data.quickReplies);
	}
};

function parseQuickReplies(quickRepliesData) {
	if (!quickRepliesData) {
		return null;
	}

	function makeQuickReplyObjectsFromArray(quickRepliesArray) {
		if (!quickRepliesArray) return null;

		let quickReplyObjects = [];
		for (var i = 0; i < quickRepliesArray.length; i++) {
			quickReplyObjects.push(new QuickReply(quickRepliesArray[i]));
		}
		return quickReplyObjects;
	}

	let quickReplies = {};
	if (Array.isArray(quickRepliesData)) {
		quickReplies.default = makeQuickReplyObjectsFromArray(quickRepliesData);
	} else {
		for (var key in quickRepliesData) {
			if (quickRepliesData.hasOwnProperty(key)) {
				quickReplies[key] = makeQuickReplyObjectsFromArray(quickRepliesData[key]);
			}
		}
	}
	return quickReplies;
}
