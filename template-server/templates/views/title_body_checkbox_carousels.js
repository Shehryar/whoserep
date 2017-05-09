const CancelSubmitScrollView = require('./cancel_submit_scroll_view');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	const scrollContentData = data && data.root ? data.root.scrollContent || {} : {};
	const title = scrollContentData.title;
	const bodyText = scrollContentData.bodyText;
	const sections = scrollContentData.sections;
	
	let items = [];
	if (title) {
		items.push(new Components.Label({
			text: title,
			style: {
				textType: 'header2'
			}
		}));
	}
	if (bodyText) {
		items.push(new Components.Label({
			text: bodyText,
			style: {
				textType: 'body',
				marginTop: title ? 16 : 0
			}
		}));
	}
	if (sections) {
		for (var i = 0; i < sections.length; i++) {
			let sectionData = sections[i];
			sectionData.style = Object.assign({
				marginTop: title || bodyText || i > 0 ? 32 : 0
			}, sectionData.style);
			items.push(new Templates.BoldBodyDetailCheckboxCarousel(sectionData));
		}
	}

	data.root.scrollContent = new Components.StackView({
		items: items,
		style: {
			padding: '36 24'
		}
	});

	CancelSubmitScrollView.call(this, data);
};
