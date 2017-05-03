// stack-view.js
// ===============

module.exports = {

	orientation: {
		horizontal: "horizontal",
		vertical: "vertical"
	},

	/**
		Data:
			text: String
			style: Dictionary
	*/
	
	build: function(data) {
		var view = {
			type: "stackView",
			content: {
				items: []
			}
		}

		if (data.orientation) view.content.orientation = data.orientation;
		if (data.items) view.content.items = data.items;
		if (data.style) view.style = data.style;
		return view;
	}
}