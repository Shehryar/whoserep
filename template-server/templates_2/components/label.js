// label.js

const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "label";
	this.content = {
		text: data.text
	};
};
