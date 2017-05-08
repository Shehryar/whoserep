const Components = require('../components');

module.exports = function(data) {
	// Properties
	const detailText = data.detailText;
	const headerText = data.headerText;

	// Content
	data.orientation = 'vertical';
	data.items = [];
	if (detailText) {
		data.items.push(new Components.Label({
			text: detailText,
			style: { 
				textType: 'detail2',
				marginBottom: (detailText && headerText) ? 4 : 0 
			}
		}));
	}
	if (headerText) {
		data.items.push(new Components.Label({
			text: headerText,
			style: {
				textType: 'header1'
			}
		}));
	}

	// Base Component
	Components.StackView.call(this, data);
};
