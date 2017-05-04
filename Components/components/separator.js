// separator.js
// ==============

module.exports = {

	style: {
		vertical: "vertical",
		horizontal: "horizontal"
	},
	
	build: function(data) {
		var separator = {
			type: "separator"
		};
		if (data) {
			if (data.separatorStyle) separator.content = { style: data.separatorStyle };
			if (data.class) separator.class = data.class;
			if (data.style) separator.style = style;
		}
		return separator;
	}
}