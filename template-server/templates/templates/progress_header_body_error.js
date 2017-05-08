// progress_bold_detail_error.js

const Components = require('../components');

module.exports = function(data) {
	// Properties
	const fillPercentage = data.fillPercentage;
	const progressBarColor = data.progressBarColor;
	const headerText = data.headerText;
	const icon = data.icon;
	const detailText = data.detailText;
	const errorText = data.errorText;

	// Default Styling
	data.style = Object.assign({
		paddingTop: 24,
		paddingBottom: 24
	}, data.style);

	// Content
	data.orientation = 'vertical';
	let progressBarStyle = {
		marginBottom: (headerText || icon || detailText || errorText) ? 20 : 0
	};
	if (progressBarColor) {
		progressBarStyle.color = progressBarColor;
	}

	data.items = [
		new Components.ProgressBar({
			fillPercentage: fillPercentage,
			style: progressBarStyle
		})
	];

	const headerMarginBottom = (detailText || errorText) ? 4 : 0;
	if (headerText && icon) {
		data.items.push(new Components.StackView({
			orientation: "horizontal",
			items: [
				new Components.Label({
					text: headerText,
					style: {
						textType: "header1",
						gravity: "middle",
						marginRight: 8
					}
				}),
				new Components.Icon({
					icon: icon,
					style: {
						width: 20,
						height: 20,
						gravity: "middle"
					}
				})
			],
			style: {
				align: "center",
				marginBottom: headerMarginBottom
			}
		}));
	} else if (headerText) {
		data.items.push(new Components.Label({
			text: headerText,
			style: {
				textType: "header1",
				align: "center",
				marginBottom: headerMarginBottom
			}
		}));
	} else if (icon) {
		data.items.push(new Components.Icon({
			icon: icon,
			style: {
				width: 20,
				height: 20,
				marginBottom: headerMarginBottom
			}
		}));
	}

	if (detailText) {
		data.items.push(new Components.Label({
			text: detailText,
			style: {
				align: "center",
				marginBottom: errorText ? 12 : 0,
				textType: "body"
			}
		}))
	}

	if (errorText) {
		data.items.push(new Components.Label({
			text: errorText,
			style: {
				align: "center",
				textType: "error"
			}
		}));
	}

	// Base Component
	Components.StackView.call(this, data);
};
