// icon_text_detail_value.js

const Components = require('../components');
const TextDetail = require('./text_detail');

module.exports = function(data) {
	// Properties
	const icon = data.icon;
	const text = data.text;
	const detail = data.detailText;
	const value = data.valueText;

	// Content
	data.orientation = 'horizontal';
	data.items = [];
	if (icon) {
		data.items.push(new Components.Icon({
			icon: icon,
			style: {
				weight: 0,
				gravity: 'middle',
				height: 12,
				width: 12,
				marginRight: 16
			}
		}));
	}
	if (text || detail) {
		data.items.push(new TextDetail({
			text: text,
			detailText: detail,
			style: {
				gravity: 'middle',
				weight: 1,
				marginRight: value ? 8 : 0
			}
		}));
	}
	if (value) {
		data.items.push(new Components.Label({
			text: value,
			style: {
				textType: 'bodyBold',
				gravity: 'middle',
				align: 'right',
				textAlign: 'right'
			}
		}));
	}

	// Base Component
	Components.StackView.call(this, data);
};
