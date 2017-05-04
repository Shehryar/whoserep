var _ = require('../components/all');

module.exports = {
  
  build: function() {
    return _.componentView.build({
      title: "Transaction History",
      styles: {
        header: {
          textType: "subheader",
          backgroundColor: "#f3f4f6",
          padding: "6 24"
        },
        row: {
          padding: "12 24"
        }
      },
      body: _.tableView.build({
        sections: [
          _.tableView.section.build({
            header: _.label.build({
              text: "2017",
              class: "header"
            }),
            rows: [
              _.textDetailValue.build({
                text: "+1 (555) 123-4567",
                detail: "3/3/2017 - 4:14PM",
                value: "$0.25",
                class: "row"
              }),
              _.textDetailValue.build({
                text: "Mom",
                detail: "3/3/2017 - 4:04PM",
                value: "$0.10",
                class: "row"
              }),
              _.textDetailValue.build({
                text: "+1 (555) 123-4567",
                detail: "3/3/2017 - 1:43PM",
                value: "$0.10",
                class: "row"
              }),
              _.textDetailValue.build({
                text: "",
                detail: "",
                value: "",
                class: "row"
              })
            ]
          }),
          _.tableView.section.build({
            header: _.label.build({
              text: "2016",
              class: "header"
            }),
            rows: [
              _.textDetailValue.build({
                text: "December 2016 Statement",
                detail: "12/26/2016",
                value: "$89.99",
                class: "row"
              })
            ]
          })
        ]
      })
    });
  }
}
