// table_view_section.js

module.exports = function(data) {
	if (data.header) this.header = data.header;
	if (data.rows) this.rows = data.rows;
};
