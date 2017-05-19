const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "slider";
	if (data) {
		if (data.label) this.content.label = data.label;
		if (data.min || data.min == 0) this.content.min = data.min;
		if (data.max) this.content.max = data.max;
	}
};
