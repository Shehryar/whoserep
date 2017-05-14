const Components = require('../components');

module.exports = function(data) {
	// Properties
	const items = data.items || [];
	const buttonTitle = data.buttonTitle;
	const buttonAction = data.buttonAction;

	// Content
	let verticalItems = [];

	// title      |
	// -----------|
	// body+detail|
	// -----------|
	// button     |


	// Title
	let titleRowItems = [];
	for (let i = 0; i < items.length; i++) {
		const item = items[i];
		const title = item.title;
		titleRowItems.push(new Components.Label({
			text: title,
			style: {
				padding: '12 16',
				textType: 'bodyBold',
				textAlign: 'center',
				align: 'fill',
				gravity: 'middle',
				weight: 1
			}
		}));

		if (i < items.length - 1) {
			titleRowItems.push(new Components.Separator({
				separatorStyle: 'vertical',
				style: {
					gravity: 'fill'
				}
			}));
		}
	}
	verticalItems.push(new Components.StackView({
		orientation: 'horizontal',
		items: titleRowItems
	}));
	verticalItems.push(new Components.Separator({
		style: {
			align: 'fill'
		}
	}));

 	// Body
	let bodyItems = [];
	for (let i = 0; i < items.length; i++) {
		const item = items[i];
		const bodyText = item.bodyText;
		const detailText = item.detailText;

		let verticalBodyItems = [];

		function addBodyText(text, marginTop, addToItems) {
			verticalBodyItems.push(new Components.Label({
				text: text,
				style: {
					textAlign: 'center',
					align: 'center',
					marginTop: marginTop
				}
			}));
		}

		if (Array.isArray(bodyText)) {
			for (let j = 0; j < bodyText.length; j++) {
				addBodyText(bodyText[j], j > 0 ? 8 : 0);
			}
		} else if (bodyText) {
			addBodyText(bodyText, 0);
		}

		if (detailText) {
			verticalBodyItems.push(new Components.Label({
				text: detailText,
				style: {
					marginTop: bodyText ? 8 : 0,
					textType: 'detail2',
					textAlign: 'center',
					align: 'center'
				}
			}));
		}

		if (verticalBodyItems.length > 0) {
			bodyItems.push(new Components.StackView({
				items: verticalBodyItems,
				style: {
					padding: 16,
					weight: 1,
					align: 'fill',
					gravity: 'fill'
				}
			}));

			if (i < items.length - 1) {
				bodyItems.push(new Components.Separator({
					separatorStyle: 'vertical',
					style: {
						gravity: 'fill'
					}
				}));
			}
		}
	}
	if (bodyItems.length > 0) {
		verticalItems.push(new Components.StackView({
			orientation: 'horizontal',
			items: bodyItems
		}));


		if (buttonTitle && buttonAction) {
			verticalItems.push(new Components.Separator({
				style: {
					align: 'fill'
				}
			}));

			verticalItems.push(new Components.Button({
				title: buttonTitle,
				action: buttonAction, 
				style: {
					align: 'fill',
					textAlign: 'center',
					buttonType: 'textPrimary'
				}
			}));
		}
	}

	data.items = verticalItems;

	// Base Component
	Components.StackView.call(this, data);
};
