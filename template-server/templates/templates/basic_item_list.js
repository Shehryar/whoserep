// basic_item_list.js

const Components = require('../components');
const IconTextDetailValue = require('./icon_text_detail_value');

module.exports = function(data) {
	// Properties
	const items = data.items;

	// Content
	data.orientation = 'vertical';
	data.items = [];
	for (var i = 0; i < items.length; i++) {
		const itemData = items[i];
		data.items.push(new IconTextDetailValue({
			icon: itemData.icon,
			text: itemData.text,
			detailText: itemData.detailText,
			valueText: itemData.valueText,
			style: {
				padding: "12 0"
			}
		}));

		if (i < items.length - 1) {
			data.items.push(new Components.Separator());
		}
	}

	// Base Component
	Components.StackView.call(this, data);
};
