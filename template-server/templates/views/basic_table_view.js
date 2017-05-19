const ComponentView = require('./component_view');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	const headerData = data.root.header;
	const sectionsData = data.root.sections;

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
	if (headerData && headerData.template) {
		try {
			var headerTemplate = require('../templates/' + headerData.template);
		} catch (err) {
			console.log('Unable to find template: ' + headerData.template);
			console.log(err);
		}

		if (headerTemplate) {
			try {
				var headerObject = new headerTemplate(headerData.data);
			} catch (err) {
				console.log('Unable to build header template object');
				console.log(err);
			}

			if (headerObject) {
				sections.push(new Components.TableViewSection({
					header: headerObject
				}));
			} else {
				console.log('Failed to create header object.');
			}
		}
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
	data.root = new Components.TableView({
		sections: sections,
		style: {
			gravity: 'fill'
		}
	});

	ComponentView.call(this, data);
};
