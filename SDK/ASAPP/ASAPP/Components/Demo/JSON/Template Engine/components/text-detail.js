// text-detail.js
// ==============

var stackView = require('./stack-view');
var label = require('./label');

module.exports = {
	
	build: function(data) {

		return stackView.build({
			orientation: stackView.orientation.vertical,
			items: [
				label.build({
					text: data.text,
					style: {
						"marginBottom": 4
					}
				}),
				label.build({
					text: data.detail,
					style: {
						textType: "detail2"
					}
				})
			],
			style: data.style
		});
	}
}