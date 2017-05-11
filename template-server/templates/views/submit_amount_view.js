const TitleBodyItemsCancelSubmit = require('./title_body_items_cancel_submit');
const Components = require('../components');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	data.root.scrollContent = data.root.scrollContent || {};
	if (!data.root.scrollContent.title) {
		data.root.scrollContent.title = "Enter Amount";
	}
	const content = data.root.scrollContent;
	const placeholder = content.existingPhoneLabel || 'AMOUNT ($)';

	var items = [];
	items.push(new Components.TextInput({
		name: 'amount',
		placeholder: placeholder, 
		textInputType: 'decimal'
	}));
	data.root.scrollContent.items = items;

	TitleBodyItemsCancelSubmit.call(this, data);
};
