const Components = require('../components');
const TitleButton = require('./title_button');

module.exports = function(data) {
	// Properties
	const boldText = data.boldText;
	const buttonTitle = data.buttonTitle;
	const buttonAction = data.buttonAction;
	const content = data.content;
	const detailText = data.detailText;

	// Default Styling
	data.style = Object.assign({
		padding: "4 20 20 20"
	}, data.style);

	// Content
	data.orientation = 'vertical';
	data.items = [];
	data.items.push(new TitleButton({
		title: boldText,
		buttonTitle: buttonTitle,
		buttonAction: buttonAction
	}));
	if (detailText) {
		data.items.push(new Components.Label({
			text: detailText,
			style: {
				textType: 'detail2',
				marginTop: 4
			}
		}));
	}
	
	// Base Component
	Components.StackView.call(this, data);
};
