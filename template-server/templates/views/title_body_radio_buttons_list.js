const TitleBodyItemsCancelSubmit = require('./title_body_items_cancel_submit');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	data.root.scrollContent = data.root.scrollContent || {};
	const content = data.root.scrollContent;
	let radioButtonsContainer = content.radioButtonsContainer || {};
	const radioButtons = radioButtonsContainer.radioButtons || {};

	console.log('radiobuttonscontainer:');
	console.log(radioButtonsContainer);
	console.log('-----');

console.log('radiobuttons:');
	console.log(radioButtons);
	console.log('-----');

	var items = [];
	for (let i = 0; i < radioButtons.length; i++) {
		let radioButton = radioButtons[i];

		console.log('1. item:');
		console.log(radioButton);
		console.log('---')
		radioButton.style = Object.assign({
			marginTop: i > 0 ? 8 : 0
		}, radioButton.style);

		items.push(new Templates.HorizontalBoldDetailValueRadioButtonView(radioButton));
	}

	radioButtonsContainer.root = new Components.StackView({ items: items });

	data.root.scrollContent.items = [
		new Components.RadioButtonsContainer(radioButtonsContainer)
	];

	TitleBodyItemsCancelSubmit.call(this, data);
};
