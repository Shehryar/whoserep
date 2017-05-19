// icon.js

const Component = require('./component');

module.exports = function(data) {
	if (data.iconSize) {
		data.style = data.style || {};
		switch (data.iconSize) {
			case 'small':
				data.style.width = 10;
				data.style.height = 10;
				break;

			case 'medium':
				data.style.width = 20;
				data.style.height = 20;
				break;

			case 'mediumLarge':
				data.style.width = 24;
				data.style.height = 24;
				break;

			case 'large':
				data.style.width = 30;
				data.style.height = 30;
				break;
		}
	}

	Component.call(this, data);

	this.type = "icon";
	this.content = {
		icon: data.icon
	};
};
