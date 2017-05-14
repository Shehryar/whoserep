const Components = require('../components');
const RadioButtonView = require('./horizontal_bold_detail_value_radio_button_view');

module.exports = function(data) {
	// Properties
	const radioButtons = data.radioButtons;

	// Content
	var items = [];
	for (var i = 0; i < radioButtons.length; i++) {
		let radioButton = radioButtons[i];
		radioButton.style = Object.assign({
			marginTop: i > 0 ? 8 : 0
		}, radioButton.style);
		items.push(new RadioButtonView(radioButton));
	}

	data.root = new Components.StackView({
		items: items
	});

	// Base Component
	Components.RadioButtonsContainer.call(this, data);
};
