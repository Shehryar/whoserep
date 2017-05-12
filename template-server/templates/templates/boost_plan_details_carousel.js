const Components = require('../components');
const BoostPlanDetails = require('./boost_plan_details');

module.exports = function(data) {
	// Properties
	const plans = data.plans || [];

	if (plans.length == 1) {
		BoostPlanDetails.call(this, plans[0]);
		return;
	}

	// Content
	var items = [];
	for (var i = 0; i < plans.length; i++) {
		const planData = plans[i];
		items.push(new BoostPlanDetails(planData));
	}

	
	data.items = items;
	data.visibleItemCount = 1;
	data.itemSpacing = 0;
	data.pagingEnabled = true;
	data.pageControl = new Components.PageControl();

	// Base Component
	Components.CarouselView.call(this, data);
};
