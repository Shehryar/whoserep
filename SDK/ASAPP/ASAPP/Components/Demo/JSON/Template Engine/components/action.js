// action.js
// =========

module.exports = {

	componentView: {

		displayStyle: {
			inset: "inset",
			full: "full"
		},

		build: function(data) {
			var action = {
				type: "componentView",
				content: {
					name: data.name,
				}
			};
			if (data.displayStyle) action.content.displayStyle = data.displayStyle;

			return action;
		}
	}
}