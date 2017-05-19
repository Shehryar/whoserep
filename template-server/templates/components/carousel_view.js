const Component = require('./component');

module.exports = function(data) {
	Component.call(this, data);

	this.type = "carouselView";
	this.content = {
		items: data.items,
	};

	if (data.itemSpacing != null) this.content.itemSpacing = data.itemSpacing;
	if (data.visibleItemCount != null) this.content.visibleItemCount = data.visibleItemCount;
	if (data.pageControl) this.content.pageControl = data.pageControl;
	if (data.pagingEnabled) this.content.pagingEnabled = data.pagingEnabled;
};
