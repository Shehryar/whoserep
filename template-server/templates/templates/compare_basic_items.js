const Components = require('../components');

module.exports = function(data) {
	// Properties
	const items = data.items || [];

	// Content
	
	let horizontalItems = [];
	for (let i = 0; i < items.length; i++) {
		const item = items[i];

		const title = item.title;
		const bodyText = item.bodyText;
		const detailText = item.detailText;

		let verticalItems = [];
		if (title) {
			verticalItems.push(new Components.Label({
				text: title,
				style: {
					padding: '10 16',
					textType: 'bodyBold',
					textAlign: 'center',
					align: 'center'
				}
			}));
			if (bodyText || detailText) {
				verticalItems.push(new Components.Separator({
					style: {
						align: 'fill'
					}
				}));
			}
		}

		if (bodyText) {
			verticalItems.push(new Components.Label({
				text: bodyText,
				style: {
					padding: "0 16",
					marginTop: 16,
					textAlign: 'center',
					align: 'center'
				}
			}));
		}
		if (detailText) {
			verticalItems.push(new Components.Label({
				text: detailText,
				style: {
					padding: "0 16",
					marginTop: bodyText ? 8 : 16,
					textType: 'detail2',
					textAlign: 'center',
					align: 'center'
				}
			}));
		}

		if (verticalItems.length > 0) {

			horizontalItems.push(new Components.StackView({
				items: verticalItems,
				style: {
					weight: 1,
					align: 'fill',
					gravity: 'fill',
					paddingBottom: 16
				}
			}));

			if (i < items.length - 1) {
				horizontalItems.push(new Components.Separator({
					separatorStyle: 'vertical',
					style: {
						gravity: 'fill'
					}
				}));
			}
		}
	}

	data.orientation = 'horizontal';
	data.items = horizontalItems;

	// Base Component
	Components.StackView.call(this, data);
};
