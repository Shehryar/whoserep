// text-detail.js
// ==============

var stackView = require('./stack-view');
var textDetail = require('./text-detail');
var label = require('./label');

module.exports = {
	
	build: function(data) {

		return stackView.build({
			orientation: stackView.orientation.horizontal,
			items: [
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
			],
			class: data.class,
			style: data.style
		});
	}
}