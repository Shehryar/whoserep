// component_view_attachment.js

const Attachment = require('./Attachment');

module.exports = function(data) {
	Attachment.call(this, data);

	this.type = "componentView";
};
