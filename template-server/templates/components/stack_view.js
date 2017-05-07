// stack_view.js

const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "stackView";
	this.content = {
		items: data.items
	};
	if (data.orientation) this.content.orientation = data.orientation;
};
