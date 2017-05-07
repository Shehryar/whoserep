var _ = require('../components');

module.exports = {
  
  build: function() {
    return _.chatMessage.build({
      text: "Sure! Here is your current account balance, upcoming charge and due date.",
      attachment: _.componentViewAttachment.build({
          body: _.accountBalance.build({
            balanceLabel: "ACCOUNT BALANCE",
            balance: "$50.00",
            icon: _.icon.icon.checkmarkThin,
            detail: "Account balance sufficient to cover your next month of service and will be automatically applied by the due date.",
            upcomingChargeLabel: "UPCOMING CHARGE",
            upcomingCharge: "$50.00",
            dueByLabel: "DUE BY",
            dueBy: "02/26/17"
          })
        }),
      quickReplies: [
        _.quickReply.treewalk.build("Option 1", ""),
        _.quickReply.treewalk.build("Option 2", ""),
        _.quickReply.treewalk.build("Option 3", "")
      ]
    });
  }
}
