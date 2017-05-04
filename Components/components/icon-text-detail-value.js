// icon-text-detail-value.js
// =========================

var stackView = require('./stack-view');
var textDetail = require('./text-detail');
var label = require('./label');
var icon = require('./icon');

module.exports = {
	
	build: function(data) {

		return stackView.build({
			class: data.class,
			style: data.style,
			orientation: stackView.orientation.horizontal,
			items: [
				icon.build({
					icon: data.icon,
					style: {
						weight: 0,
						gravity: "middle",
						height: 12,
						width: 12,
						marginRight: 16
					}
				}),
				textDetail.build({
					text: data.text,
					detail: data.detail,
					style: {
						weight: 1,
						gravity: "middle",
						marginRight: 8
					}
				}),
				label.build({
					text: data.value,
					style: {
						textType: "bodyBold",
						gravity: "middle",
						align: "right",
						textAlign: "right"
					}
				})
			]
		});
	}
}