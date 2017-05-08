const Message = require('./message');
const ComponentViewAttachment = require('./component_view_attachment');
const Templates = require('../templates');

module.exports = function(data) {
	const attachmentContent = data.attachment || {};

	let attachment = new ComponentViewAttachment({
		content: {
			body: new Templates.TitleButtonContent({
				title: attachmentContent.title,
				buttonTitle: attachmentContent.buttonTitle,
				buttonAction: attachmentContent.buttonAction,
				content: new Templates.ProgressHeaderDetailError(attachmentContent.content)
			})
		}
	});

	Message.call(this, data, attachment);
};
