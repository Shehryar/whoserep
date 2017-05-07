// title_button_content.js

var Components = require('../components');
var TitleButton = require('./title_button');

module.exports = function(data) {
	// Properties
	const title = data.title;
	const buttonTitle = data.buttonTitle;
	const buttonAction = data.buttonAction;
	const content = data.content;

	// Default Styling
	data.style = Object.assign({
		padding: "4 20 4 20"
	}, data.style);

	// Content
	data.orientation = 'vertical';
	data.items = [
		new TitleButton({
			title: title,
			buttonTitle: buttonTitle,
			buttonAction: buttonAction
		}),
		new Components.Separator(),
		content
	];

	// Base Component
	Components.StackView.call(this, data);
};
