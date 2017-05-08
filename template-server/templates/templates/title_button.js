const Components = require('../components');

module.exports = function(data) {
	// Properties
	const title = data.title;
	const buttonTitle = data.buttonTitle;
	const buttonAction = data.buttonAction;

	// Content
	data.orientation = 'horizontal';
	data.items = [];
	if (title) {
		data.items.push(new Components.Label({
			text: title,
			style: { 
				textType: 'bodyBold',
				weight: 1,
				gravity: 'middle',
				marginRight: (title && buttonTitle && buttonAction) ? 8 : 0 
			}
		}));
	}
	if (buttonTitle && buttonAction) {
		data.items.push(new Components.Button({
			title: buttonTitle,
			action: buttonAction,
			buttonStyle: "textPrimary",
			style: {
				padding: '16 0 16 16',
				textAlign: 'right',
				align: 'right',
				gravity: 'middle'
			}
		}));
	}

	// Base Component
	Components.StackView.call(this, data);
};
