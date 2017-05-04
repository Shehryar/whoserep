// generic-table-view-view.js
// ==========================

var componentView = require('./component-view');
var tableView = require('./table-view');
var iconTextDetailValue = require('./icon-text-detail-value');
var label = require('./label');
var icon = require('./icon');

module.exports = {

	build: function(data) {
		const styles = {
			header: {
				textType: "subheader",
				backgroundColor: "#f3f4f6",
				padding: "6 24"
			},
			row: {
				padding: "12 24"
			}
	    };

	    var sections = [];
	    for (var i = 0; i < data.sections.length; i++) {
			var sectionData = data.sections[i];

			var rows = [];
			for (var j = 0; j < sectionData.rows.length; j++) {
				var rowData = sectionData.rows[j];
				rows.push(iconTextDetailValue.build({
					icon: rowData.icon,
					text: rowData.text,
					detail: rowData.detail,
					value: rowData.value,
					class: "row" 
				}));
			}

			var header = null;
			if (sectionData.header) {
				header = label.build({
					text: sectionData.header,
					class: "header"
				})
			}

	    	sections.push(tableView.section.build({
				header: header,
	        	rows: rows
	      	}));
	    }

	    // Build the table view
	    return componentView.build({
	    	title: data.title,
			styles: styles,
	   		body: tableView.build({
	        	sections: sections
	      	})
	    });
	}
}