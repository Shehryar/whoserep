
// Components
var _ = require('./components/all');

function build() {
	return _.chatMessage.build({
		text: "Sure! Here are your last three calls. Tap 'view all' to see your full talk history.",
		attachment: _.componentViewAttachment.build({
				body: _.separatedList.build({
					items: [
						_.titleButton.build({
							title: "Transaction History",
							buttonTitle: "VIEW ALL",
							buttonAction: _.action.componentView.build({
								name: "1-2_view_talk_history"
							})
						}),
						_.textDetailValue.build({
							text: "+1 (555) 123-4567",
							detail: "3/3/2017 - 4:14PM",
							value: "0:25",
							style: {
								padding: "12 0"
							}
						}),
						_.textDetailValue.build({
							text: "Mom",
							detail: "2/3/2017 - 10:33AM",
							value: "09:14",
							style: {
								padding: "12 0"
							}
						}),
						_.textDetailValue.build({
							text: "+1 (555) 123-4567",
							detail: "1/3/2017 - 8:07PM",
							value: "07:02",
							style: {
								padding: "12 0"
							}
						})
					],
					style: {
						padding: "0 20"
					}
				})
			}),
		quickReplies: [
			_.quickReply.treewalk.build("quick reply 1", "qr1"),
			_.quickReply.treewalk.build("quick reply 2", "qr2"),
			_.quickReply.treewalk.build("quick reply 3", "qr3")
		]
	});
}
console.log(JSON.stringify(build(), null, 2));
