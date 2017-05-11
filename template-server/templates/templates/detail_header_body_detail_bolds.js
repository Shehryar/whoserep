const Components = require('../components');
const DetailHeader = require('./detail_header');
const DetailBold = require('./detail_bold');
const IconBoldBodyDetail = require('./icon_bold_body_detail');

module.exports = function(data) {
	// Properties
	const detailTextTop = data.detailTextTop;
	const headerTextTop = data.headerTextTop;
	const hasTopSection = (detailTextTop || headerTextTop);

	const icon = data.icon;
	const boldText = data.boldText;
	const bodyText = data.bodyText;
	const errorText = data.errorText;
	const detailText = data.detailText;
	const hasMiddleSection = (icon || boldText || bodyText || errorText || detailText);

	const detailTextBottom1 = data.detailTextBottom1;
	const boldTextBottom1 = data.boldTextBottom1;
	const detailTextBottom2 = data.detailTextBottom2;
	const boldTextBottom2 = data.boldTextBottom2;
	const hasBottomSection = (detailTextBottom1 || boldTextBottom1 || detailTextBottom2 || boldTextBottom2);
	
	// Default Style
	data.style = Object.assign({
		padding: 20
	}, data.style);

	// Content
	let items = [];
	if (hasTopSection) {
		items.push(new DetailHeader({
			detailText: detailTextTop,
			headerText: headerTextTop,
			style: {
				marginBottom: hasMiddleSection || hasBottomSection ? 12 : 0
			}
		}));
	}
	if (hasMiddleSection) {
		items.push(new IconBoldBodyDetail({
			icon: icon,
			boldText: boldText,
			bodyText: bodyText,
			detailText: detailText,
			errorText: errorText,
			style: {
				marginBottom: hasBottomSection ? 20 : 0
			}
		}));
	}
	if (hasBottomSection) {
		const hasLeftSide = (detailTextBottom1 || boldTextBottom1);
		const hasRightSide = (detailTextBottom2 || boldTextBottom2);

		let bottomItems = [];
		if (hasLeftSide) {
			bottomItems.push(new DetailBold({
				detailText: detailTextBottom1,
				boldText: boldTextBottom1,
				style: {
					weight: hasRightSide ? 1 : 0,
					marginRight: hasRightSide ? 10 : 0
				}
			}))
		}
		if (hasRightSide) {
			bottomItems.push(new DetailBold({
				detailText: detailTextBottom2,
				boldText: boldTextBottom2,
				style: {
					weight: 1
				}
			}));
		}

		items.push(new Components.StackView({
			orientation: 'horizontal',
			items: bottomItems
		}))
	}

	data.items = items;

	// Base Component
	Components.StackView.call(this, data);
};
