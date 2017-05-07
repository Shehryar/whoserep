const _ = require('./templates_2');

let testObject = null;

testObject = new _.Templates.TitleButton({
	title: 'Bill Summary',
	buttonTitle: 'DETAILS',
	buttonAction: {
		type: 'componentView',
		content: {
			name: 'componet name'
		}
	}
});

testObject = new _.Messages.TitleButtonBasicItemList({
	text: 'Hello, world!',
	attachment: {
		title: 'March 2017 Statement',
		buttonTitle: 'View Details',
		buttonAction: {
			type: 'componentView',
			content: {
				name: 'viewName12345'
			}
		},
		items: [
			{
				icon: 'alert',
				text: 'Header Text 1',
				detailText: '03/04/2017',
				valueText: '$110.97'
			}
		]
	},
	quickReplies: [
		{
			title: 'Test Quick Reply',
			action: {
				type: 'treewalk',
				content: {
					classification: 'BBQ'
				}
			}
		}
	]
});

console.log(JSON.stringify(testObject, null, 2));

// console.log(.
// 	JSON.stringify(
// 	Object.assign(
// 		{
// 			name: 'Mitchell Morgan',
// 			age: '27'
// 		}, 
// 		{
// 			name: 'NOT Mitch',
// 			bigMuscles: true
// 		}),
// 	null, 2));

