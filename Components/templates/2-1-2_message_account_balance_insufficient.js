var _ = require('../components/all');

module.exports = {
  
  build: function() {
    return _.chatMessage.build({
      text: "Sure! Here is your current account balance, upcoming charge and due date.",
      attachment: _.componentViewAttachment.build({
          body: _.accountBalance.build({
            balanceLabel: "ACCOUNT BALANCE",
            balance: "$0.00",
            icon: _.icon.icon.alertWarning,
            detail: "Account balance insufficient to cover your next month of service.",
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
