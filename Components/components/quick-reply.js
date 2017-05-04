// quick-reply.js
// ==============

module.exports = {
	
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
