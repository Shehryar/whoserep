const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "radioButtonsContainer";
	this.content = {
		root: data.root
	};
};
