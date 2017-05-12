const ComponentView = require('./component_view');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	const currentPlan = data.currentPlan;
	const currentPlanTitle = data.currentPlanTitle || "CURRENT PLAN";
	const compareToPlans = data.compareToPlans;
	const compareToPlansTitle = data.compareToPlansTitle || "AVAILABLE PLANS"

	// Content
	var pages = [];

	if (currentPlan) {
		pages.push(new Components.TabViewPage({
			title: currentPlanTitle,
			root: new Templates.BoostPlanDetails(currentPlan)
		}));
	}

	if (compareToPlans) {
		pages.push(new Components.TabViewPage({
			title: compareToPlansTitle,
			root: new Templates.BoostPlanDetailsCarousel({
				plans: compareToPlans
			})
		}));
	}

	data.root = new Components.TabView({
		value: data.openToPage,
		pages: pages,
		style: {
			align: 'fill',
			gravity: 'fill'
		}
	});

	ComponentView.call(this, data);
};


