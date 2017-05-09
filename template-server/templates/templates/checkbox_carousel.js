const Components = require('../components');
const BoldBodyDetailCheckbox = require('./bold_body_detail_checkbox');

module.exports = function(data) {
	// Properties
	const title = data.title;
	const checkboxItems = data.items;

	// Content
	var items = [];
	if (title) {
		items.push(new Components.Label({
			text: title,
			style: {
				textType: 'bodyBold',
				marginBottom: checkboxItems ? 16 : 0
			}
		}));
	}
	if (checkboxItems) {
		var carouselItems = [];
		for (let i = 0; i < checkboxItems.length; i++) {
			carouselItems.push(new BoldBodyDetailCheckbox({

			}));
		}
		
	}

	data.items.push(new TitleButton({
		title: title,
		buttonTitle: buttonTitle,
		buttonAction: buttonAction
	}));
	if (!hideSeparator) {
		data.items.push(new Components.Separator());
	}
	if (content) {
		data.items.push(content);
	}
	data.items = [];

	// Base Component
	Components.StackView.call(this, data);
};
