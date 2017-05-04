var _ = require('../components/all');

module.exports = {
  
  build: function() {
    return _.chatMessage.build({
      text: "Sure! Here are your last three transactions. Tap 'view all' to see your full transaction history.",
      attachment: _.componentViewAttachment.build({
          body: _.separatedList.build({
            items: [
              _.titleButton.build({
                title: "Transaction History",
                buttonTitle: "VIEW ALL",
                buttonAction: _.action.componentView.build({
                  name: "1-1_view_transaction_history"
                })
              }),
              _.textDetailValue.build({
                text: "March 2017 Bill Statement",
                detail: "3/3/2017",
                value: "$110.97",
                style: {
                  padding: "12 0"
                }
              }),
              _.textDetailValue.build({
                text: "February 2017 Bill Statement",
                detail: "2/3/2017",
                value: "$110.97",
                style: {
                  padding: "12 0"
                }
              }),
              _.textDetailValue.build({
                text: "Upgrade Services",
                detail: "1/3/2017",
                value: "$34.66",
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
        _.quickReply.treewalk.build("Texts", "1-3_message_text_history"),
        _.quickReply.treewalk.build("Calls", "1-2_message_talk_history")
      ]
    });
  }
}
