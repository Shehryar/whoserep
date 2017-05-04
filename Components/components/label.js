// label.js
// ========

module.exports = {
	
	/**
		text: String
		style: Dictionary
	*/
	build: function(data) {
		var label = {
			type: "label",
			content: {}
		};
		if (data.text) label.content.text = data.text;
		if (data.style) label.style = data.style;
		return label;
	}
}