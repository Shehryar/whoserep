// table_view.js

const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "tableView";
	this.content = {
		sections: data.sections
	};
};
