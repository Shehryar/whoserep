// title-button-detail.js
// =========================

const Components = require('../components');

module.exports = {

	testData: {
		title: "General Terms & Conditions",
		buttonTitle: "VIEW",
		buttonAction: {

		},
		detailText: "AS OF JAN 22, 2017 - 4:15PM"
	},
	
	build: function(data) {
		data = data || testData;

		return Components.stackView.build({
			style: {
				padding: "5 20 20 20",
				align: "fill"
			},
			class: data.class,
			items: [
				Components.stackView.build({
					style: {
						marginBottom: 4
					},
					orientation: Components.stackView.orientation.horizontal,
					items: [
						Components.label.build({
							text: data.title,
							style: {
								textType: "bodyBold",
								marginBottom: 12,
								weight: 1,
								gravity: "middle"
							}
						}),
						Components.button.build({
							style: {
								weight: 0,
								gravity: "middle",
								align: "right",
								textAlign: "right",
								padding: "16 0 16 16"
							},
							title: data.buttonTitle,
							action: data.buttonAction,
							buttonStyle: Components.button.style.textPrimary
						})
					]
				}),
				Components.label.build({
					text: data.detailText,
					style: {
						textType: "detail2"
					}
				})
			]
		});
	}
}