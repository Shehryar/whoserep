const Components = require('../components');
const BoostPlanLimits = require('./boost_plan_limits');

module.exports = function(data) {
	// Properties
	const planName = data.planName;
	const dataLimit = data.dataLimit;
	const textLimit = data.textLimit;
	const talkLimit = data.talkLimit;
	const basePrice = data.basePrice;
	const addOns = data.addOns; // { text, valueText }
	const discounts = data.discounts;
	const summaryText = data.summaryText;
	const summaryValueText = data.summaryValueText;

	// Content
	var scrollItems = [];

	if (planName) {
		scrollItems.push(new Components.Label({
			text: planName,
			style: {
				textType: 'header2',
				align: 'center'
			}
		}));
	}
	if (dataLimit || textLimit || talkLimit) {
		scrollItems.push(new BoostPlanLimits({
			dataLimit: dataLimit,
			textLimit: textLimit,
			talkLimit: talkLimit,
			style: {
				marginTop: planName ? 32 : 0,
				marginBottom: 16
			}
		}));
	}
	if (basePrice) {
		scrollItems.push(new Components.StackView({
			orientation: 'horizontal',
			style: {
				marginTop: 32
			},
			items: [
				new Components.Label({
					text: 'Plan Base',
					style: {
						textType: 'bodyBold',
						weight: 1,
						gravity: 'middle',
						marginRight: 10
					}
				}),
				new Components.Label({
					text: basePrice,
					style: {
						texttype: 'bodyBold',
						align: 'right',
						textAlign: 'right',
						gravity: 'middle'
					}
				})
			]
		}));
	}

	function addDetailItemsList(title, detailItems) {
		scrollItems.push(new Components.Separator({
			style: {
				margin: "16 0"
			}
		}));
		scrollItems.push(new Components.Label({
			text: title,
			style: {
				marginBottom: 3,
				textType: 'bodyBold'
			}
		}));
		for (var i = 0; i < detailItems.length; i++) {
			const itemData = detailItems[i];
			scrollItems.push(new Components.StackView({
				orientation: 'horizontal',
				items: [
					new Components.Label({
						text: itemData.text,
						style: {
							weight: 1,
							gravity: 'middle',
							marginRight: 10
						}
					}),
					new Components.Label({
						text: itemData.valueText,
						style: {
							gravity: 'middle',
							weight: 0,
							align: 'right',
							textAlign: 'right'
						}
					})
				],
				style: {
					marginTop: 4
				}
			}));
		}
	}
	if (addOns) {
		addDetailItemsList('Add-ons', addOns);
	}
	if (discounts) {
		addDetailItemsList('Discounts', discounts);
	}

	// Scroll Content

	const scrollView = new Components.ScrollView({
		root: new Components.StackView({
			items: scrollItems,
			style: {
				padding: 32
			}
		}),
		style: {
			weight: 1
		}
	});


	const fixedBottomView = new Components.StackView({
		items: [
			new Components.Separator({
				style: { 
					align: 'fill',
					marginBottom: 16
				}
			}),
			new Components.StackView({
				orientation: 'horizontal',
				items: [
					new Components.Label({
						text: summaryText,
						style: {
							weight: 1,
							textType: 'header2',
							gravity: 'middle',
							marginRight: 10
						}
					}),
					new Components.Label({
						text: summaryValueText,
						style: {
							textType: 'header2',
							gravity: 'middle',
							align: 'right',
							textAlign: 'right'
						}
					})
				]
			})
		],
		style: {
			padding: "0 32 20 32",
			weight: 0,
			align: 'fill'
		}
	});

	data.items = [scrollView, fixedBottomView];

	// Base Component
	Components.StackView.call(this, data);
};
