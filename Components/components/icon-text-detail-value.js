// icon-text-detail-value.js
// =========================

var stackView = require('./stack-view');
var textDetail = require('./text-detail');
var label = require('./label');
var icon = require('./icon');

module.exports = {
	
	build: function(data) {

		var items = [];
		if (data.icon) {
			items.push(icon.build({
				icon: data.icon,
				style: {
					weight: 0,
					gravity: "middle",
					height: 12,
					width: 12,
					marginRight: 16
				}
			}));
		}

		if (data.text || data.detail) {
			items.push(textDetail.build({
				text: data.text,
				detail: data.detail,
				style: {
					weight: 1,
					gravity: "middle",
					marginRight: 8
				}
			}));
		}

		if (data.value) {
			items.push(label.build({
				text: data.value,
				style: {
					textType: "bodyBold",
					gravity: "middle",
					align: "right",
					textAlign: "right"
				}
			}));
		}

		return stackView.build({
			class: data.class,
			style: data.style,
			orientation: stackView.orientation.horizontal,
			items: items
		});
	}
}