var _ = require('../components/all');


const data = {
  title: "Data Usage",
  dataUsage: {
    fillPercentage: 0.45,
    text: "200GB",
    icon: null,
    detail: "of 450GB",
    alert: null
  },
  sections: [
    {
      header: "March 2017",
      rows: [
        {
          "text": "Sample Content",
          "detail": "3/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "3/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "3/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "3/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "3/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "3/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "3/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "3/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "3/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "3/3/2017",
          "value": "FPO"
        }
      ]
    },
    {
      header: "February 2017",
      rows: [
        {
          "text": "Sample Content",
          "detail": "2/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "2/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "2/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "2/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "2/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "2/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "2/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "2/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "2/3/2017",
          "value": "FPO"
        },
        {
          "text": "Sample Content",
          "detail": "2/3/2017",
          "value": "FPO"
        }
      ]
    }
  ]
}



module.exports = {
  
  build: function() {

    var styles = {
      row: {
        padding: "12 24"
      },
      header: {
        textType: "subheader",
        backgroundColor: "#f3f4f6",
        padding: "6 24"
      }
    };

    var sections = [];

    // Data Usage
    if (data.dataUsage) {
      sections.push({
        header: _.stackView.build({
          style: {
            padding: "40 24 24 24"
          },
          items: [
            _.progressBar.build({
              fillPercentage: data.dataUsage.fillPercentage,
              style: {
                marginBottom: 20
              }
            }),
            _.label.build({
              text: data.dataUsage.text,
              style: {
                textType: "header1",
                align: "fill",
                textAlign: "center",
                marginBottom: 4
              }
            }),
            _.label.build({
              text: data.dataUsage.detail,
              style: {
                textType: "body",
                align: "fill",
                textAlign: "center"
              }
            })
          ]
        })  
      });
    }

    // Line Items
    if (data.sections) {
      for (var i = 0; i < data.sections.length; i++) {
        var header = null;
        var sectionData = data.sections[i];
        if (sectionData.header) {
          header = _.label.build({
            text: sectionData.header,
            class: "header"
          });
        }

        var rows = [];
        for (var j = 0; j < sectionData.rows.length; j++) {
          var rowData = sectionData.rows[j];
          rows.push(_.textDetailValue.build({
            text: rowData.text,
            detail: rowData.detail,
            value: rowData.value,
            class: "row"
          }));
        }

        sections.push({
          header: header,
          rows: rows
        });
      }
    }

    return _.componentView.build({
      title: data.title,
      styles: styles,
      body: _.tableView.build({
        sections: sections
      })
    });
  }
}