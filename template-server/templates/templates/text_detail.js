// text_detail.js

const Components = require('../components');

module.exports = function(data) {
	// Properties
	const text = data.text;
	const detailText = data.detailText;

	// Content
	data.orientation = 'vertical';
	data.items = [];
	if (text) {
		data.items.push(new Components.Label({
			text: text,
			style: { 
				textType: 'body',
				marginBottom: (text && detailText) ? 4 : 0 
			}
		}));
	}
	if (detailText) {
		data.items.push(new Components.Label({
			text: detailText,
			style: {
				textType: 'detail1'
			}
		}));
	}

	// Base Component
	Components.StackView.call(this, data);
};
