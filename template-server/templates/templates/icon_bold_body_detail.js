const Components = require('../components');

module.exports = function(data) {
	// Properties
	const icon = data.icon;
	const iconSize = data.iconSize;
	const boldText = data.boldText;
	const bodyText = data.bodyText;
	const detailText = data.detailText;

	// Content
	if (boldText || bodyText || detailText) {
		var rightSideItems = [];
		if (boldText) {
			rightSideItems.push(new Components.Label({
				text: boldText,
				style: {
					textType: 'bodyBold'
				}
			}));
		}
		if (bodyText) {
			rightSideItems.push(new Components.Label({
				text: bodyText,
				style: {
					textType: 'body',
					marginTop: boldText ? 4 : 0
				}
			}));
		}
		if (detailText) {
			rightSideItems.push(new Components.Label({
				text: detailText,
				style: {
					textType: 'detail1',
					marginTop: boldText || bodyText ? 12 : 0
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
				marginRight: rightSide ? 16 : 0
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
		items = [rightSideItems];
	} else if (leftSide) {
		orientation = "vertical";
		items = [leftSide];
	}
	data.orientation = orientation;
	data.items = items;

	// Base Component
	Components.StackView.call(this, data);
};
