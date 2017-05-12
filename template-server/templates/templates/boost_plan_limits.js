//        |         | 
//  DATA  |  TEXT   |  TALK 
//  1GB   |  Unl.   |  Unl.
//        |         | 


const Components = require('../components');
const DetailHeader = require('./detail_header');

module.exports = function(data) {
	// Properties
	const dataLimit = data.dataLimit;
	const textLimit = data.textLimit;
	const talkLimit = data.talkLimit;

	// Default Styling
	data.orientation = 'horizontal';
	
	// Content
	function createSubview(detailText, headerText) {
		return new Components.StackView({
			style: {
				weight: 1,
				padding: '16 10'
			},
			items: [
				new Components.Label({
					text: detailText,
					style: {
						textType: 'subheader',
						align: 'center'
					}
				}),
				new Components.Label({
					text: headerText,
					style: {
						textType: 'header1',
						align: 'center'
					}
				})
			]
		});
	}

	function createSeparator() {
		return new Components.Separator({
			separatorStyle: 'vertical',
			style: { 
				gravity: 'fill' 
			}
		});
	}

	var items = [];
	if (dataLimit) {
		items.push(createSubview("4G LTE DATA", dataLimit));
	}
	if (textLimit) {
		if (dataLimit) items.push(createSeparator());
		items.push(createSubview("TEXT", textLimit));
	}
	if (talkLimit) {
		if (dataLimit || textLimit) items.push(createSeparator());
		items.push(createSubview("TALK", talkLimit));
	}
	data.items = items;

	// Base Component
	Components.StackView.call(this, data);
};
