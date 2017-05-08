const ComponentView = require('./component_view');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.body = data.body || {};
	const headerData = data.body.header;
	const sectionsData = data.body.sections;

	// Default Styles
	data.styles = Object.assign({
		header: {
			textType: "subheader",
			backgroundColor: "#f3f4f6",
			padding: "6 24"
		},
		row: {
			padding: "12 24"
		}
	}, data.styles);

	// Content
	let sections = [];
	if (headerData) {
		sections.push({ header: headerData });
	}
	if (sectionsData && sectionsData.length > 0) {
		for (var i = 0; i < sectionsData.length; i++) {
			var sectionData = sectionsData[i];

			if (sectionData.headerText) {
				var header = new Components.Label({
					text: sectionData.headerText,
					class: "header"
				});
			}

			var rows = [];
			for (var j = 0; j < sectionData.rows.length; j++) {
				var rowData = Object.assign({
					class: "row"
				}, sectionData.rows[j]);
				rows.push(new Templates.IconTextDetailValue(rowData));
			}

	    	sections.push(new Components.TableViewSection({
				header: header,
	        	rows: rows
	      	}));
	    }
	}
	data.body = new Components.TableView({
		sections: sections,
		style: {
			gravity: 'fill'
		}
	});

	ComponentView.call(this, data);
};
