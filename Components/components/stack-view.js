// stack-view.js
// ===============

module.exports = {

	orientation: {
		horizontal: "horizontal",
		vertical: "vertical"
	},
	
	build: function(data) {
		var view = {
			type: "stackView",
			content: {
				items: []
			}
		}

		if (data.orientation) view.content.orientation = data.orientation;
		if (data.items) view.content.items = data.items;
		if (data.class) view.class = data.class;
		if (data.style) view.style = data.style;
		return view;
	}
}