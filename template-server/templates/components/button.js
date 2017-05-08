// button.js

const Component = require('./component');
const Action = require('./action');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "button";
	this.content = {
		title: data.title,
		action: new Action(data.action)
	};

	if (data.buttonStyle) this.content.buttonStyle = data.buttonStyle;
	if (data.icon) this.content.icon = data.icon;
};
