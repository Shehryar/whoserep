const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "radioButton";
	
	// No content
};
