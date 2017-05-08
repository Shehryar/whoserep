module.exports = function(data) {
	this.body = data.body;
	if (data.title) this.title = data.title;
	if (data.styles) this.styles = data.styles;
};
