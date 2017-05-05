// chat-template-message.js
// ===============

var Components = require('../components');

module.exports = {

	build: function(data) {
		var message = {};
		if (data.text) message.text = data.text;

		if (data.templateName) {
			try {
				var template = require('./' + data.templateName);
			} catch (err) {
				console.log('Unable to import template: ' + data.templateName);
				console.log(err);
			}
			
			if (template) {
				const attachmentView = template.build(data.templateData);
				if (attachmentView) {
					message.attachment = Components.componentViewAttachment.build({
						body: attachmentView
					});
				}
			}			
		}
		
		if (data.quickReplies) {
			let quickReplies = [];
			for (var i = 0; i < data.quickReplies.length; i++) {
				const quickReplyData = data.quickReplies[i];
				let quickReply = Components.quickReply.build(quickReplyData);
				if (quickReply) {
					quickReplies.push(quickReply);
				}
			}
			if (quickReplies.length > 0) {
				message.quickReplies = quickReplies;
			}
		}

		return message;
	} 
};
