const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);
	
	this.type = "tabView";
	this.content = {
		pages: data.pages
	};
};
