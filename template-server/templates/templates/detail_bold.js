const Components = require('../components');

module.exports = function(data) {
	// Properties
	const detailText = data.detailText;
	const boldText = data.boldText;

	// Content
	data.orientation = 'vertical';
	data.items = [];
	if (detailText) {
		data.items.push(new Components.Label({
			text: detailText,
			style: { 
				textType: 'detail2',
				marginBottom: (detailText && boldText) ? 4 : 0 
			}
		}));
	}
	if (boldText) {
		data.items.push(new Components.Label({
			text: boldText,
			style: {
				textType: 'bodyBold'
			}
		}));
	}

	// Base Component
	Components.StackView.call(this, data);
};
