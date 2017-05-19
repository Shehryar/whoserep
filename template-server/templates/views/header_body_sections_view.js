const ComponentView = require('./component_view');
const Components = require('../components');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	const sections = data.root.sections || []; // { title, bodyText}

	// Contents
	let items = [];
	for (var i = 0; i < sections.length; i++) {
		const section = sections[i];
		// Title
		if (section.title) {
			items.push(new Components.Label({
				text: section.title,
				style: {
					textType: 'header2',
					marginTop: i > 0 ? 32 : 0,
					marginBottom: section.bodyText ? 16 : 0
				}
			}));
		}

		// Body 
		function addBodyText(text, useMargin) {
			items.push(new Components.Label({
				text: text,
				style: {
					textType: 'body',
					marginTop: useMargin ? 16 : 0
				}
			}));
		}
		if (Array.isArray(section.bodyText)) {
			for (var j = 0; j < section.bodyText.length; j++) {
				addBodyText(section.bodyText[j], j > 0);
			}
		} else if (section.bodyText) {
			addBodyText(section.bodyText, false);
		}
	}

	// StackView inside ScrollView
	data.root = new Components.ScrollView({
		root: new Components.StackView({
			items: items,
			style: {
				padding: 32
			}
		})
	});

	ComponentView.call(this, data);
};
