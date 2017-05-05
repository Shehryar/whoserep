// icon.js
// ==============

module.exports = {

	icon: {
		alertError: "alertError",
		alertWarning: "alertWarning",
		arrowOutgoing: "arrowOutgoing",
		checkmarkCircle: "checkmarkCircle",
		checkmarkThick: "checkmarkThick",
		checkmarkThin: "checkmarkThin",
		placeholder: "placeholder",
		power: "power",
		trash: "trash",
		user: "user",
		userMinus: "userMinus",
		xThick: "xThick",
		xThin: "xThin"
	},

	build: function(data) {
		var icon = {
			type: "icon",
			content: {}
		};
		if (data.icon) icon.content.icon = data.icon;
		if (data.class) icon.class = data.class;
		if (data.style) icon.style = data.style;
		return icon;
	}
}