// button.js

const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "button";
	this.content = {
		title: data.title,
		action: data.action
	};

	if (data.buttonStyle) this.content.style = data.buttonStyle;
	if (data.icon) this.content.icon = data.icon;
};
