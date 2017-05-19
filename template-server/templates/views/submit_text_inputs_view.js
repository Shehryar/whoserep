const TitleBodyItemsCancelSubmit = require('./title_body_items_cancel_submit');
const Components = require('../components');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	data.root.scrollContent = data.root.scrollContent || {};
	const content = data.root.scrollContent;
	const textInputs = content.textInputs || [];
	const moreText = content.moreText || [];

	var items = [];
	for (let i = 0; i < textInputs.length; i++) {

		let item = textInputs[i];
		item.style = Object.assign({
			marginTop: i > 0 ? 16 : 0
		}, item.style);

		items.push(new Components.TextInput(item));
	}
	for (let i = 0; i < moreText.length; i++) {
		items.push(new Components.Label({
			text: moreText[i],
			style: {
				marginTop: i == 0 ? 32 : 16
			}
		}));
	}

	data.root.scrollContent.items = items;

	TitleBodyItemsCancelSubmit.call(this, data);
};
