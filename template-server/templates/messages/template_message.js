const Message = require('./message');
const ComponentViewAttachment = require('./component_view_attachment');

module.exports = function(data) {
	const templateName = data.template;

	try {
		var Template = require('../templates/' + templateName);
	} catch(err) {
		console.log('Unable to find template: ' + templateName);
		console.log(err);
	}

	if (Template) {
		const templateData = data && data.attachment ? data.attachment : {};
		try {
			var templateOutput = new Template(templateData);
		} catch(err) {
			console.log("Unable to generate template out.");
			console.log(err);
		}

		if (templateOutput) {
			var attachment = new ComponentViewAttachment({
				content: {
					root: templateOutput
				}
			});
		}
	}

	Message.call(this, data, attachment);
};
