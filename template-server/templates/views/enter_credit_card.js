const TitleBodyItemsCancelSubmit = require('./title_body_items_cancel_submit');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	data.root.scrollContent = data.root.scrollContent || {};
	const content = data.root.scrollContent;

	// Content
	var items = [];
	function addInput(name, placeholder, textInputType) {
		items.push(new Components.TextInput({
			name: name,
			placeholder: placeholder,
			textInputType: textInputType,
			style: {
				marginTop: 24
			}
		}));
	}

	addInput('name', 'NAME ON CARD');
	addInput('cardNumber', 'CARD NUMBER', 'number');
	items.push(new Templates.HorizontalTextInputs({
		textInputs: [
			{
				name: 'cardExp',
				placeholder: 'EXP DATE (MM/YY)'
			},
			{
				name: 'cardCVV',
				placeholder: 'SECURITY CODE',
				textInputType: 'number'
			}
		],
		style: {
			marginTop: 24
		}
	}));
	addInput('address1', 'BILLING ADDRESS LINE 1');
	addInput('address2', 'APT / SUITE (OPTIONAL)');
	addInput('city', 'CITY');
	items.push(new Templates.HorizontalTextInputs({
		textInputs: [
			{
				name: 'state',
				placeholder: 'STATE'
			},
			{
				name: 'zip',
				placeholder: 'ZIP CODE'
			}
		],
		style: {
			marginTop: 24
		}
	}));


	data.root.scrollContent.items = items;

	TitleBodyItemsCancelSubmit.call(this, data);
};
