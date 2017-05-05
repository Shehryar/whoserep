var _ = require('../components/all');

module.exports = {
  
  build: function() {
    return _.chatMessage.build({
      text: "Sure! Here are your last three transactions. Tap 'view all' to see your full transaction history.",
      attachment: _.componentViewAttachment.build({
          body: _.titleButtonGenericList.build({
            title: "Transaction History",
            buttonTitle: "VIEW ALL",
            buttonAction: _.action.componentView.build({
              name: "1-1_view_transaction_history"
            }),
            items: [
              {
                text: "March 2017 Bill Statement",
                detail: "3/3/2017 - 4:14PM",
                value: "$110.97"
              },
              {
                text: "February 2017 Bill Statement",
                detail: "2/3/2017 - 10:33AM",
                value: "$110.97"
              },
              {
                text: "Upgrade Services",
                detail: "1/3/2017 - 8:07PM",
                value: "$34.66"
              }
            ]
          }),
        }),
      quickReplies: [
        _.quickReply.treewalk.build("Data Usage", "1-4_message_data_usage"),
        _.quickReply.treewalk.build("Texts", "1-3_message_text_history"),
        _.quickReply.treewalk.build("Calls", "1-2_message_talk_history")
      ]
    });
  }
}
