const Message = require('./message');
const ComponentViewAttachment = require('./component_view_attachment');
const Templates = require('../templates');

module.exports = function(data) {
	const attachmentContent = data.attachment || {};

	let attachment = new ComponentViewAttachment({
		content: {
			body: new Templates.DetailHeaderBodyDetailBolds(attachmentContent)
		}
	});

	Message.call(this, data, attachment);
};
