var _ = require('../components/all');

const data = {
  title: "Text History",
  sections: [
    {
      header: "2017",
      rows: [
        {
          icon: _.icon.icon.arrowOutgoing,
          text: "+1 (555) 123-4567",
          detail: "3/3/2017 - 4:14PM",
          value: "$0.25"
        },
        {
          icon: _.icon.icon.arrowOutgoing,
          text: "Mom",
          detail: "3/3/2017 - 4:04PM",
          value: "$0.10"
        },
        {
          icon: _.icon.icon.arrowOutgoing,
          text: "+1 (555) 123-4567",
          detail: "2/28/2017 - 8:07PM",
          value: "$0.34"
        },
        {
          icon: _.icon.icon.placeholder,
          text: "+1 (555) 123-4567",
          detail: "3/3/2017 - 1:43PM",
          value: "$0.10"
        },
        {
          icon: _.icon.icon.arrowOutgoing,
          text: "+1 (555) 123-4567",
          detail: "2/14/2017 - 4:04PM",
          value: "$0.15"
        },
        {
          icon: _.icon.icon.arrowOutgoing,
          text: "+1 (555) 123-4567",
          detail: "1/30/2017 - 1:02PM",
          value: "$0.25"
        },
        {
          icon: _.icon.icon.placeholder,
          text: "Billy",
          detail: "1/15/2017 - 8:54PM",
          value: "$0.95"
        },{
          icon: _.icon.icon.placeholder,
          text: "Mom",
          detail: "1/4/2017 - 10:34AM",
          value: "$01.63"
        }
      ],
    },
    {
      header: "2016",
      rows: [
        {
          icon: _.icon.icon.arrowOutgoing,
          text: "Billy",
          detail: "12/25/2016 - 5:34PM",
          value: "$0.23"
        },
        {
          icon: _.icon.icon.placeholder,
          text: "Billy",
          detail: "12/18/2016 - 5:12PM",
          value: "$0.62"
        },
        {
          icon: _.icon.icon.arrowOutgoing,
          text: "Mom",
          detail: "12/14/2016 - 6:54PM",
          value: "$0.25"
        },
        {
          icon: _.icon.icon.placeholder,
          text: "+1 (555) 123-4567",
          detail: "12/1/2016 - 1:24PM",
          value: "$01.50"
        },
        {
          icon: _.icon.icon.arrowOutgoing,
          text: "Mom",
          detail: "3/2/2017 - 12:31PM",
          value: "$0.35"
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
