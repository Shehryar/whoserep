// component.js

module.exports = function(data) {
	if (data) {
		if (data.class) this.class = data.class;
		if (data.id) this.id = data.id;
		if (data.name) this.name = data.name;
		if (data.style) this.style = data.style;
		if (data.value) this.value = data.value;
	}
};
