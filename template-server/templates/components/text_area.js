const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "textArea";
	this.content = {};

	if (data.autocorrect) this.content.autocorrect = data.autocorrect;
	if (data.capitalize) this.content.capitalize = data.capitalize;
	if (data.numberOfLines) this.content.numberOfLines = data.numberOfLines;
	if (data.placeholder) this.content.placeholder = data.placeholder;
};
