const Components = require('../components');

module.exports = function(data) {
	// Properties
	const boldText = data.boldText;
	const detailText = data.detailText;
	const valueText = data.valueText;

	// Default Style
	data.style = Object.assign({
		padding: 20,
		borderWidth: 1,
		cornerRadius: 6
	}, data.style);

	// Content
	var items = [];

	var middleItems = [];
	if (boldText) {
		middleItems.push(new Components.Label({
			text: boldText,
			style: {
				textType: 'bodyBold'
			}
		}));
	}
	if (detailText) {
		middleItems.push(new Components.Label({
			text: detailText,
			style: {
				textType: 'detail1',
				marginTop: boldText ? 4 : 0
			}
		}));
	}
	items.push(new Components.StackView({
		items: middleItems,
		style: {
			weight: 1,
			gravity: 'middle'
		}
	}));

	if (valueText) {
		items.push(new Components.Label({
			text: valueText,
			style: {
				gravity: 'middle',
				align: 'right',
				textAlign: 'right',
				textType: 'bodyBold',
				marginLeft: 16
			}
		}));
	}

	data.orientation = 'horizontal';
	data.items = items;

	// Base Component
	Components.StackView.call(this, data);
};
