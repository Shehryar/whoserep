const TitleBodyItemsCancelSubmit = require('./title_body_items_cancel_submit');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	data.root.scrollContent = data.root.scrollContent || {};
	const content = data.root.scrollContent;
	const existingPhoneLabel = content.existingPhoneLabel || 'BOOST PHONE';
	const existingPhone = content.existingPhone;

	// Content
	var items = []
	if (existingPhone) {
		items.push(new Components.Label({
			text: existingPhoneLabel,
			style: {
				textType: 'detail1'
			}
		}));
		items.push(new Components.Label({
			text: existingPhone,
			style: {
				textType: 'body',
				marginTop: 8
			}
		}));
	}

	function addInput(name, placeholder) {
		items.push(new Components.TextInput({
			name: name,
			placeholder: placeholder,
			style: {
				marginTop: 24
			}
		}));
	}

	addInput('altPhone', 'ALTERNATE PHONE');
	addInput('email', 'EMAIL ADDRESS');
	addInput('address1', 'ADDRESS LINE 1');
	addInput('address2', 'ADDRESS LINE 2');
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
