// button.js
// ========

module.exports = {

	style: {
		primary: "primary",
		secondary: "secondary",
		textPrimary: "text",
		textSecondary: "textSecondary"
	},
	
	build: function(data) {
		var button = {
			type: "button",
			content: {
				title: data.title,
				action: data.action
			}
		};
		if (data.buttonStyle) button.content.style = data.buttonStyle;
		if (data.style) button.style = data.style;

		return button;
	}
}