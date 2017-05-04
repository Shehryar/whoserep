var _ = require('../components/all');

module.exports = {
	
	build: function() {
		return _.chatMessage.build({
			text: "Sure! Here are your last three calls. Tap 'view all' to see your full talk history.",
			attachment: _.componentViewAttachment.build({
					body: _.separatedList.build({
						style: { padding: "0 20" },
						items: [
							_.titleButton.build({
								title: "Talk History",
								buttonTitle: "VIEW ALL",
								buttonAction: _.action.componentView.build({
									name: "1-2_view_talk_history"
								})
							}),
							_.iconTextDetailValue.build({
								icon: _.icon.icon.arrowOutgoing,
								text: "+1 (555) 123-4567",
								detail: "3/3/2017 - 4:14PM",
								value: "0:25",
								style: {
									padding: "12 0"
								}
							}),
							_.iconTextDetailValue.build({
								icon: _.icon.icon.placeholder,
								text: "Mom",
								detail: "3/2/2017 - 12:31PM",
								value: "09:14",
								style: {
									padding: "12 0"
								}
							}),
							_.iconTextDetailValue.build({
								icon: _.icon.icon.arrowOutgoing,
								text: "+1 (555) 123-4567",
								detail: "2/28/2017 - 8:07PM",
								value: "07:02",
								style: {
									padding: "12 0"
								}
							})
						]
					})
				}),
			quickReplies: [
				_.quickReply.treewalk.build("Data Usage", "1-4_message_data_usage"),
       	 		_.quickReply.treewalk.build("Texts", "1-3_message_text_history"),
        		_.quickReply.treewalk.build("Payments", "1-1_message_transaction_history"),
			]
		});
	}
}
