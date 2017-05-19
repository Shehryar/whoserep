const Components = require('../components');
const BoostPhonePlanCard = require('./boost_phone_plan_card')

module.exports = function(data) {
	// Properties
	const plans = data.plans;

	if (!data.itemSpacing) data.itemSpacing = 10;
	if (!data.pagingEnabled) data.pagingEnabled = true;
	if (!data.visibleItemCount) data.visibleItemCount = 1;

	// Content
	let items = [];
	if (plans) {
		for (var i = 0; i < plans.length; i++) {
			const planData = plans[i];
			items.push(new BoostPhonePlanCard(planData));
		}
	}
	data.items = items;
	data.pageControl = new Components.PageControl();

	// Base Component
	Components.CarouselView.call(this, data);
};
