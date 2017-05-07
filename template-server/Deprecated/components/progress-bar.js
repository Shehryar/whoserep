// progress-bar.js
// ==============

module.exports = {

	build: function(data) {
		var separator = {
			type: "progressBar",
			content: {}
		};
		if (data.fillPercentage) separator.content.fillPercentage = data.fillPercentage;
		if (data.class) separator.class = data.class;
		if (data.style) separator.style = data.style;
		return separator;
	}
}