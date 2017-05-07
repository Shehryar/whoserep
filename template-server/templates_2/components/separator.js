// separator.js

const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "separator";
	if (data && data.separatorStyle) {
		this.content = {
			separatorStyle: data.separatorStyle
		};
	}
};
