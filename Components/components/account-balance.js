// account-balance.js
// ==================

var stackView = require('./stack-view');
var label = require('./label');
var icon = require('./icon');

module.exports = {
	
	testData: {
		balanceLabel: "ACCOUNT BALANCE",
		balance: "$50.00",
		icon: icon.icon.checkmarkThin,
		detail: "Account balance sufficient to cover your next month of service and will be automatically applied by the due date.",
		upcomingChargeLabel: "UPCOMING CHARGE",
		upcomingCharge: "$50.00",
		dueByLabel: "DUE BY",
		dueBy: "02/26/17"
	},

	build: function(data) {
		data = data || this.testData;

		var bottomRowItems = [];
		if (data.upcomingCharge) {
			bottomRowItems.push(stackView.build({
				orientation: stackView.orientation.vertical,
				items: [
					label.build({
						text: data.upcomingChargeLabel,
						style: {
							textType: "detail2",
							marginBottom: 4
						}
					}),
					label.build({
						text: data.upcomingCharge,
						style: {
							textType: "bodyBold"
						}
					})
				],
				style: {
					marginRight: 8,
					weight: 1,
					align: "fill"
				}
			}));
		}
		if (data.dueBy) {
			bottomRowItems.push(stackView.build({
				orientation: stackView.orientation.vertical,
				items: [
					label.build({
						text: data.dueByLabel,
						style: {
							textType: "detail2",
							marginBottom: 4
						}
					}),
					label.build({
						text: data.dueBy,
						style: {
							textType: "bodyBold"
						}
					})
				], 
				style: {
					weight: 1,
					align: "fill"
				}
			}));
		}
		
		var items = [
			label.build({
				text: data.balanceLabel,
				style: {
					textType: "detail2",
					marginBottom: 4
				}
			}),
			label.build({
				text: data.balance,
				style: {
					textType: "header1",
					marginBottom: 16
				}
			}),
			stackView.build({
				orientation: stackView.orientation.horizontal,
				items: [
					icon.build({
						icon: data.icon,
						style: {
							width: 24,
							height: 24,
							marginRight: 12
						}
					}),
					label.build({
						text: data.detail,
						style: {
							textType: "body",
						}
					})
				]
			})
		];
		if (bottomRowItems.length > 0) {
			items.push(stackView.build({
				orientation: stackView.orientation.horizontal,
				items: bottomRowItems,
				style: {
					marginTop: 20
				}
			}));
		}


		return stackView.build({
			style: {
				padding: 20
			},
			orientation: stackView.orientation.vertical,
			items: items
		});
	}
}