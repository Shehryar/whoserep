// quick_reply.js

const Components = require('../components');

module.exports = function(data) {
	this.title = data.title;
	this.action = new Components.Action(data.action);
	if (data.isAutoSelect) this.isAutoSelect = data.isAutoSelect;
};
