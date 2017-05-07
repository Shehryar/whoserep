// quick-reply.js
// ==============

module.exports = {
	
	build: function(data) {
		return {
			title: data.title,
			action: {
				type: data.type,
				content: data.content
			}
		};
	},

	treewalk: {
		build: function(title, classification) {
			return {
			title: title,
			action: {
				type: "treewalk",
				content: {
					classification: classification
				}
			}
		};
		}
	}
}
