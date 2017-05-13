const ComponentView = require('./component_view');
const Components = require('../components');
const Templates = require('../templates');

module.exports = function(data) {
	// Properties
	data.root = data.root || {};
	const labels = data.root.labels || [];

	var items = [];
	for (let i = 0; i < labels.length; i++) {
		let labelData = labels[i];
		labelData.style = Object.assign({
			margin: i > 0 ? "16 0 0 0" : 0
		}, labelData.style);
		items.push(new Components.Label(labelData));
	}

	const stackView = new Components.StackView({
		items: items,
		style: {
			padding: "32 24"
		}
	});

	data.root = new Components.ScrollView({
		root: stackView,
		style: {
			gravity: 'fill'
		}
	});

	ComponentView.call(this, data);
};
