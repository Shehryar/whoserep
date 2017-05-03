// title-button.js
// =================

var stackView = require('./stack-view');
var label = require('./label');
var button = require('./button');

module.exports = {
	
	build: function(data) {
		return stackView.build({
			orientation: stackView.orientation.horizontal,
			items: [
				label.build({
					text: data.title,
					style: {
						textType: "bodyBold",
						gravity: "middle",
						weight: 1
					}
				}),
				button.build({
					title: data.buttonTitle,
					action: data.buttonAction,
					buttonStyle: button.style.textPrimary,
					style: {
						padding: "16 0 16 16",
						textAlign: "right"
					}
				})
			],
			style: data.style
		});
	}
}
