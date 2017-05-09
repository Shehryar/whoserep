const Components = require('../components');
const BoldBodyDetailCheckboxView = require('./bold_body_detail_checkbox_view');

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
			var checkboxData = checkboxItems[i];
			checkboxData.style = Object.assign({
				gravity: 'fill'
			}, checkboxData.style);
			carouselItems.push(new BoldBodyDetailCheckboxView(checkboxData));
		}
		items.push(new Components.CarouselView({
			items: carouselItems,
			itemSpacing: 10,
			visibleItemCount: 2.1
		}));
	}
	data.items = items;

	// Base Component
	Components.StackView.call(this, data);
};
