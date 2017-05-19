const TitleBodyItemsCancelSubmit = require('./title_body_items_cancel_submit');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	data.root.scrollContent = data.root.scrollContent || {};
	const content = data.root.scrollContent;
	const checkboxes = content.checkboxes || [];

	var items = [];
	for (let i = 0; i < checkboxes.length; i++) {
		let checkboxData = checkboxes[i];
		checkboxData.style = Object.assign({
			marginTop: i > 0 ? 8 : 0
		}, checkboxData.style);

		items.push(new Templates.HorizontalBoldDetailValueCheckbox(checkboxData));
	}
	data.root.scrollContent.items = items;

	TitleBodyItemsCancelSubmit.call(this, data);
};
