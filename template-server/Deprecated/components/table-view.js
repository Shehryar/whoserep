// table-view.js
// =============

module.exports = {

	section: {

		build: function(data) {
			var section = {};
			if (data.header) section.header = data.header;
			if (data.rows) section.rows = data.rows;
			return section;
		}
	},
	
	build: function(data) {
		var tableView = {
			type: "tableView",
			content: {}
		};
		if (data.sections) tableView.content.sections = data.sections;
		if (data.class) tableView.class = data.class;
		if (data.style) tableView.style = data.style;
		return tableView;
	}
}