var _ = require('../components/all');

module.exports = {
  
  build: function() {
    return _.chatMessage.build({
      text: "Sure! Here are your last three texts. Tap 'view all' to see your full text history.",
      attachment: _.componentViewAttachment.build({
          body: _.separatedList.build({
            items: [
              _.titleButton.build({
                title: "Text History",
                buttonTitle: "VIEW ALL",
                buttonAction: _.action.componentView.build({
                  name: "1-3_view_text_history"
                })
              }),
              _.iconTextDetailValue.build({
                icon: _.icon.icon.arrowOutgoing,
                text: "+1 (555) 123-4567",
                detail: "3/3/2017 - 4:14PM",
                value: "$0.25",
                style: {
                  padding: "12 0"
                }
              }),
              _.iconTextDetailValue.build({
                icon: _.icon.icon.arrowOutgoing,
                text: "Mom",
                detail: "3/3/2017 - 4:04PM",
                value: "$0.10",
                style: {
                  padding: "12 0"
                }
              }),
              _.iconTextDetailValue.build({
                icon: _.icon.icon.placeholder,
                text: "+1 (555) 123-4567",
                detail: "3/3/2017 - 1:43PM",
                value: "$0.10",
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
        _.quickReply.treewalk.build("Data Usage", "1-4_message_data_usage"),
        _.quickReply.treewalk.build("Payments", "1-1_message_transaction_history"),
        _.quickReply.treewalk.build("Calls", "1-2_message_talk_history")
      ]
    });
  }
}
