// separated-list.js
// =================

var stackView = require('./stack-view');
var separator = require('./separator');

module.exports = {
	
	build: function(data) {
		var items = [];
		if (data.items) {
			var itemsLength = data.items.length;
			for (var i = 0; i < itemsLength; i++) {
				var item = data.items[i];
				if (item) {
					items.push(data.items[i]);
				}

				if (i < itemsLength - 1) {
					items.push(separator.build());
				}
			}
		}

		return stackView.build({
			items: items,
			style: data.style
		})
	}
}