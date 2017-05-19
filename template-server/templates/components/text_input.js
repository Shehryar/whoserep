const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "textInput";
	this.content = {};

	if (data.autocorrect) this.content.autocorrect = data.autocorrect;
	if (data.capitalize) this.content.capitalize = data.capitalize;
	if (data.password) this.content.password = data.password;
	if (data.placeholder) this.content.placeholder = data.placeholder;
	if (data.textInputType) this.content.textInputType = data.textInputType;
};
