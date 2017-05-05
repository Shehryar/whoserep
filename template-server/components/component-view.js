// component-view.js
// =================

module.exports = {
	
	build: function(data) {
		if (!data) return {};

		var view = {};
		if (data.title) view.title = data.title;
		if (data.styles) view.styles = data.styles;
		if (data.body) view.body = data.body;
		return view;
	}
}