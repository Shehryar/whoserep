const Components = require('../components');

module.exports = function(data) {
	// Properties
	const boldText = data.boldText;
	const bodyText = data.bodyText;
	const detailText = data.detailText;

	data.style = Object.assign({
		padding: "24 20 16 20",
		borderWidth: 1,
		cornerRadius: 6
	}, data.style);

	// Content
	data.orientation = 'vertical';
	var items = [];
	if (boldText) {
		items.push(new Components.Label({
			text: boldText,
			style: {
				align: "center",
				textAlign: "center",
				textType: "bodyBold"
			}
		}));
	}
	if (bodyText) {
		items.push(new Components.Label({
			text: bodyText,
			style: {
				align: "center",
				textAlign: "center",
				textType: "body",
				weight: 1,
				marginTop: boldText ? 16 : 0
			}
		}));
	}
	items.push(new Components.Checkbox({
		style: {
			align: "center",
			marginTop: boldText || bodyText ? 40 : 0
		}
	}));
	if (detailText) {
		items.push(new Components.Label({
			text: detailText,
			style: {
				align: "center",
				textAlign: "center",
				textType: "detail1",
				marginTop: 16
			}
		}));
	}
	data.root = new Components.StackView({
		items: items
	});

	// Base Component
	Components.CheckboxView.call(this, data);
};
