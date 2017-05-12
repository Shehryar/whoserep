const TitleBodyItemsCancelSubmit = require('./title_body_items_cancel_submit');
const Components = require('../components');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	data.root.scrollContent = data.root.scrollContent || {};
	const content = data.root.scrollContent;
	const textInputs = content.textInputs || [];

	var items = [];
	for (let i = 0; i < textInputs.length; i++) {

		let item = textInputs[i];
		console.log('item');
		console.log(item);
		console.log('----------');
		item.style = Object.assign({
			marginTop: i > 0 ? 16 : 0
		}, item.style);

		items.push(new Components.TextInput(item));
	}
	data.root.scrollContent.items = items;

	TitleBodyItemsCancelSubmit.call(this, data);
};
