const Components = require('../components');
const DetailHeader = require('./detail_header');

module.exports = function(data) {
	// Properties
	const planName = data.planName;
	const price = data.price;
	const details = data.details; // { detailText, headerText }
	const buttonTitle = data.buttonTitle;
	const buttonAction = data.buttonAction;

	// Default Styling
	data.style = Object.assign({
		borderWidth: 1,
		cornerRadius: 6,
		backgroundColor: '#ffffff'
	}, data.style);

	// Content
	let items = [];
	items.push(new Components.StackView({
		orientation: 'horizontal',
		style: {
			padding: '15 20'
		},
		items: [
			new Components.Label({
				text: planName,
				style: {
					weight: 1,
					textType: 'bodyBold'
				}
			}),
			new Components.Label({
				text: price,
				style: {
					align: 'right',
					textAlign: 'right',
					textType: 'bodyBold'
				}
			})
		]
	}));
	items.push(new Components.Separator({
		style: { align: 'fill' }
	}));

	let detailItems = [];
	if (details) {
		for (var i = 0; i < details.length; i++) {
			detailItems.push(new Components.StackView({
				style: {
					weight: 1,
					padding: '16 16'
				},
				items: [
					new Components.Label({
						text: details[i].detailText,
						style: {
							textType: 'subheader',
							align: 'center'
						}
					}),
					new Components.Label({
						text: details[i].headerText,
						style: {
							textType: 'header1',
							align: 'center'
						}
					})
				]
			}));
			if (i < details.length - 1) {
				detailItems.push(new Components.Separator({
					separatorStyle: 'vertical',
					style: {
						gravity: 'fill'
					}
				}));
			}
		}
	}
	items.push(new Components.StackView({
		orientation: 'horizontal',
		items: detailItems
	}));

	if (buttonTitle && buttonAction) {
		items.push(new Components.Separator({
			style: { align: 'fill' }
		}));
		items.push(new Components.Button({
			title: buttonTitle,
			action: buttonAction, 
			buttonStyle: 'textPrimary',
			style: {
				align: 'fill',
				textAlign: 'center'
			}
		}));
	}
	data.items = items;

	// Base Component
	Components.StackView.call(this, data);
};
