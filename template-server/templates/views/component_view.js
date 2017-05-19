module.exports = function(data) {
	this.root = data.root;
	if (data.title) this.title = data.title;
	if (data.styles) this.styles = data.styles;
};
