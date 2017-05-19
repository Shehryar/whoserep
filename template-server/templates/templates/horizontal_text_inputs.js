const Components = require('../components');

module.exports = function(data) {
	// Properties
	const textInputs = data.textInputs;

	// Content
	var items = [];
	if (textInputs) {
		for (var i = 0; i < textInputs.length; i++) {
			let textInputData = textInputs[i];
			textInputData.style = Object.assign({
				weight: 1,
				marginLeft: i > 0 ? 20 : 0
			}, textInputData.style);
			items.push(new Components.TextInput(textInputData));
		}
	}

	data.orientation = 'horizontal';
	data.items = items;

	// Base Component
	Components.StackView.call(this, data);
};
