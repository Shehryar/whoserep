const TitleBodyItemsCancelSubmit = require('./title_body_items_cancel_submit');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	data.root.scrollContent = data.root.scrollContent || {};
	const content = data.root.scrollContent;
	const items = content.items || [];

	var stackViewItems = [];
	for (let i = 0; i < items.length; i++) {
		let item = items[i];
		item.style = Object.assign({
			marginTop: i > 0 ? 8 : 0
		}, item.style);

		stackViewItems.push(new Templates.BoldDetailValue(item));
	}
	data.root.scrollContent.items = stackViewItems;

	TitleBodyItemsCancelSubmit.call(this, data);
};
