// component-view-attachment.js
// ============================

var componentView = require('./component-view');

module.exports = {
	
	build: function(data) {
		return {
			type: "componentView",
			content: componentView.build({
				title: data.title,
				styles: data.styles,
				body: data.body
			})
		};
	}
}