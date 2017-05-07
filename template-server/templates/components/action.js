// action.js

module.exports = function(data) {
	this.type = data.type;
	this.content = {};

	switch (this.type) {
		case 'api':
			this.content.requestPath = data.requestPath;
			if (data.data) this.content.data = data.data;
			if (data.inputFields) this.content.inputFields = data.inputFields;
			if (data.requiredInputFields) this.content.requiredInputFields = data.requiredInputFields;
			break;

		case 'componentView':
			this.content.name = data.name;
			if (data.displayStyle) this.content.displayStyle = data.displayStyle;
			break;

		case 'deepLink':
			this.content.name = data.name;
			if (data.data) this.content.data = data.data;
			break;

		case 'finish':
			// No content
			break;

		case 'treewalk':
			this.content.classification = data.classification;
			break;

		case 'web':
			this.content.url = data.url;
			break;
	}
};
