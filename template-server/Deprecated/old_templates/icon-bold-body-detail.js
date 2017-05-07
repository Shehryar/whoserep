// icon-text-detail-value.js
// =========================

const Components = require('../components');

module.exports = {

	testData: {
		icon: Components.icon.icon.checkmarkThin,
		boldText: "Payment Complete",
		bodyText: "You've sucecssfully made a payment of $42.27 using your card ending in 9087 to the account associated the the phone number +1 (555) 111-5555",
		detailText: "MAR 15, 2017 - 4:15PM"
	},
	
	build: function(data) {
		data = data || testData;

		var horizontalItems = [];
		if (data.icon) {
			horizontalItems.push(Components.icon.build({
				icon: data.icon,
				style: {
					gravity: "top",
					height: 30,
					width: 30,
					marginRight: 24
				}
			}));
		}

		var verticalItems = [];
		if (data.boldText) {
			const boldMarginBottom = (data.boldText && data.bodyText) ? 6 : 0;
			verticalItems.push(Components.label.build({
				text: data.boldText,
				style: {
					textType: "bodyBold",
					marginBottom: boldMarginBottom
				}
			}));
		}
		if (data.bodyText) {
			const bodyMarginBottom = (data.bodyText && data.detailText) ? 12 : 0;
			verticalItems.push(Components.label.build({
				text: data.bodyText,
				style: {
					textType: "body",
					marginBottom: bodyMarginBottom
				}
			}));
		}
		if (data.detailText) {
			verticalItems.push(Components.label.build({
				text: data.detailText,
				style: {
					textType: "detail2"
				}
			}));
		}
		horizontalItems.push(Components.stackView.build({
			items: verticalItems
		}));

		var style = data.style || {};
		if (!style.padding) {
			style.padding = 20;
		}
		return Components.stackView.build({
			style: style,
			orientation: Components.stackView.orientation.horizontal,
			items: horizontalItems
		});
	}
}