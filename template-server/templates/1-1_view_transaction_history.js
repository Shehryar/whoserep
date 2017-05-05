var _ = require('../components');

const data = {
  title: "Transaction History",
  sections: [
    {
      header: "2017",
      rows: [
        {
          text: "March 2017 Bill Statement",
          detail: "3/3/2017 - 4:14PM",
          value: "$110.97",
        },
        {
          text: "February 2017 Bill Statement",
          detail: "2/3/2017 - 10:33AM",
          value: "$110.97",
        },
        {
          text: "Upgrade Services",
          detail: "1/3/2017 - 8:07PM",
          value: "$34.66",
        },
        {
          text: "January 2017 Bill Statement",
          detail: "1/3/2017 - 4:14PM",
          value: "$110.07",
        },
        {
          text: "Late Fees",
          detail: "1/2/2017 - 12:38PM",
          value: "$70.03",
        }
      ],
    },
    {
      header: "2016",
      rows: [
        {
          text: "December 2016 Bill Statement",
          detail: "12/3/2016 - 4:14PM",
          value: "$110.97",
        },
        {
          text: "November 2016 Bill Statement",
          detail: "11/3/2016 - 10:33AM",
          value: "$110.97",
        },
        {
          text: "October 2016 Bill Statement",
          detail: "10/3/2016 - 4:14PM",
          value: "$110.07",
        }
      ]
    }
  ]
}

module.exports = {
  build: function() {
    return _.genericTableViewView.build(data);
  }
}
