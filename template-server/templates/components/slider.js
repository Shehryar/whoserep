const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "slider";
	if (data) {
		if (data.fillPercentage) this.fillPercentage = data.fillPercentage;
	}
};
