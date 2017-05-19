const Components = require('../components');
const DetailHeader = require('./detail_header');

module.exports = function(data) {
	// Properties
	const planName = data.planName;
	const price = data.price;
	const details = data.details; // { detailText, headerText }
	const header1 = data.header1;
	const header2 = data.header2;
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
	if (planName || price) {
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
	}

	if (header1 || header2) {
		if (items.length > 0) {
			items.push(new Components.Separator({
				style: { align: 'fill' }
			}));
		}

		if (header1) {
			items.push(new Components.Label({
				text: header1,
				style: {
					textType: 'header1',
					padding: "0 24",
					marginTop: 24,
					marginBottom: header2 ? 0 : 24,
					align: 'center',
					textAlign: 'center'
				}
			}));
		}
		if (header2) {
			items.push(new Components.Label({
				text: header2,
				style: {
					textType: 'header1',
					padding: "0 24",
					marginTop: header1 ? 8 : 24,
					marginBottom: 24,
					align: 'center',
					textAlign: 'center'
				}
			}));
		}
	}

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
	if (detailItems.length > 0) {
		if (items.length > 0) {
			items.push(new Components.Separator({
				style: { align: 'fill' }
			}));
		}

		items.push(new Components.StackView({
			orientation: 'horizontal',
			items: detailItems
		}));
	}

	if (buttonTitle && buttonAction) {
		if (items.length > 0) {
			items.push(new Components.Separator({
				style: { align: 'fill' }
			}));
		}
		
		items.push(new Components.Button({
			title: buttonTitle,
			action: buttonAction, 
			style: {
				buttonType: 'textPrimary',
				align: 'fill',
				textAlign: 'center'
			}
		}));
	}
	data.items = items;

	// Base Component
	Components.StackView.call(this, data);
};
