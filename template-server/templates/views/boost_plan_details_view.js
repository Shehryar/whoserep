const ComponentView = require('./component_view');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	let planInfo = data.root || {};

	// Default Styles
	planInfo.style = Object.assign({
		gravity: 'fill',
		align: 'fill'
	}, planInfo.style);

	// Content
	data.root = new Templates.BoostPlanDetails(planInfo);

	ComponentView.call(this, data);
};
