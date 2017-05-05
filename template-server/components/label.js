// label.js
// ========

module.exports = {
	
	build: function(data) {
		var label = {
			type: "label",
			content: {}
		};
		if (data.text) label.content.text = data.text;
		if (data.class) label.class = data.class;
		if (data.style) label.style = data.style;
		return label;
	}
}