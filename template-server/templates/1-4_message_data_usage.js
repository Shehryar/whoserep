var _ = require('../components/all');

module.exports = {
  
  build: function() {
    return _.chatMessage.build({
      text: "Sure! Here are your last three transactions. Tap 'view all' to see your full transaction history.",
      attachment: _.componentViewAttachment.build({
          body: _.separatedList.build({
            items: [
              _.titleButton.build({
                title: "Data Usage",
                buttonTitle: "VIEW DETAILS",
                buttonAction: _.action.componentView.build({
                  name: "1-4_view_data_usage"
                })
              }),
              _.stackView.build({
                items: [
                  _.progressBar.build({
                    fillPercentage: 0.45,
                    style: {
                      marginBottom: 20
                    }
                  }),
                  _.label.build({
                    text: "200GB",
                    style: {
                      textType: "bodyBold",
                      align: "fill",
                      textAlign: "center",
                      marginBottom: 8
                    }
                  }),
                  _.label.build({
                    text: "of 450GB",
                    style: {
                      textType: "detail1",
                      align: "fill",
                      textAlign: "center"
                    }
                  })
                ],
                style: {
                  padding: 20
                }
              })
            ],
            style: {
              padding: "0 20"
            }
          })
        }),
      quickReplies: [
        _.quickReply.treewalk.build("Texts", "1-3_message_text_history"),
        _.quickReply.treewalk.build("Payments", "1-1_message_transaction_history"),
        _.quickReply.treewalk.build("Calls", "1-2_message_talk_history")
      ]
    });
  }
}
