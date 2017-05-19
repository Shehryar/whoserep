const Components = require('../components');
const TitleButton = require('./title_button');

module.exports = function(data) {
	// Properties
	const title = data.title;
	const buttonTitle = data.buttonTitle;
	const buttonAction = data.buttonAction;
	const content = data.content;
	const hideSeparator = data.hideSeparator;

	// Default Styling
	data.style = Object.assign({
		padding: "4 20 4 20"
	}, data.style);

	// Content
	data.orientation = 'vertical';
	data.items = [];
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


	// Base Component
	Components.StackView.call(this, data);
};
