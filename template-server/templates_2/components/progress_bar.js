// progress_bar.js

const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "progressBar";
	this.content = {};
	if (data.fillPercentage) this.content.fillPercentage = data.fillPercentage;
};
