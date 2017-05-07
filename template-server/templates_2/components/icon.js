// icon.js

const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "icon";
	this.content = {
		icon: data.icon
	};
};
