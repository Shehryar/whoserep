// all.js
// ======

module.exports = {
	
	chatMessage: require('./chat-message'),
	componentView: require('./component-view'),
	componentViewAttachment: require('./component-view-attachment'),

	// Data-bound Views
	genericTableViewView: require('./generic-table-view-view'),

	// Combination Components
	titleButton: require('./title-button'),
	textDetail: require('./text-detail'),
	textDetailValue: require('./text-detail-value'),
	iconTextDetailValue: require('./icon-text-detail-value'),
	separatedList: require('./separated-list'),
	titleButtonGenericList: require('./title-button-generic-list'),

	// Base Components
	action: require('./action'),
	icon: require('./icon'),
	label: require('./label'),
	quickReply: require('./quick-reply'),
	progressBar: require('./progress-bar'),
	separator: require('./separator'),
	stackView: require('./stack-view'),
	tableView: require('./table-view')
}