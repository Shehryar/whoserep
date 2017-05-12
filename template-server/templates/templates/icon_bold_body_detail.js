const Components = require('../components');

module.exports = function(data) {
	// Properties
	const icon = data.icon;
	const iconSize = data.iconSize;
	const boldText = data.boldText;
	const bodyText = data.bodyText;
	const errorText = data.errorText;
	const detailText = data.detailText;

	// Content
	if (boldText || bodyText || detailText || errorText) {
		var rightSideItems = [];
		if (boldText) {
			rightSideItems.push(new Components.Label({
				text: boldText,
				style: {
					textType: 'bodyBold'
				}
			}));
		}

		function addBodyText(text, marginTop) {
			rightSideItems.push(new Components.Label({
				text: text,
				style: {
					textType: 'body',
					marginTop: marginTop
				}
			}));
		}
		if (Array.isArray(bodyText)) {	
			for (let i = 0; i < bodyText.length; i++) {
				let marginTop = 0;
				if (boldText && i == 0) {
					marginTop = 8;
				} else if (i > 0) {
					marginTop = 8;
				}

				addBodyText(bodyText[i], marginTop);
			}
		} else if (bodyText) {
			addBodyText(bodyText, boldText ? 12 : 0);
		}
		if (errorText) {
			rightSideItems.push(new Components.Label({
				text: errorText,
				style: {
					textType: 'error',
					marginTop: bodyText || boldText ? 12 : 0
				}
			}));
		}
		if (detailText) {
			rightSideItems.push(new Components.Label({
				text: detailText,
				style: {
					textType: 'detail1',
					marginTop: errorText || boldText || bodyText ? 12 : 0
				}
			}));
		}

		var rightSide = new Components.StackView({
			items: rightSideItems,
			style: {
				gravity: 'top'
			}
		});
	}

	if (icon) {
		var leftSide = new Components.Icon({
			icon: icon,
			iconSize: data.iconSize || 'medium',
			style: {
				gravity: 'top',
				weight: 0,
				marginRight: rightSide ? 20 : 0
			}
		});
	}

	let orientation = "vertical";
	let items = [];
	if (leftSide && rightSide) {
		orientation = "horizontal";
		items = [leftSide, rightSide];
	} else if (rightSide) {
		orientation = "vertical";
		items = rightSideItems;
	} else if (leftSide) {
		orientation = "vertical";
		items = [leftSide];
	}
	data.orientation = orientation;
	data.items = items;

	// Base Component
	Components.StackView.call(this, data);
};
