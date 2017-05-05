var _ = require('../components');

var separatedList = require('./separated-list');
var titleButton = require('./title-button');
var iconTextDetailValue = require('./icon-text-detail-value');
var action = require('./action');

module.exports = {
  
  build: function(data) {
    
    var items = [];
    if (data.title || data.buttonTitle) {
      items.push(titleButton.build({
        title: data.title,
        buttonTitle: data.buttonTitle,
        buttonAction: data.buttonAction,
      }));
    }

    for (var i = 0; i < data.items.length; i++) {
      var itemData = data.items[i];
      items.push(iconTextDetailValue.build({
        icon: itemData.icon,
        text: itemData.text,
        detail: itemData.detail,
        value: itemData.value,
        style: {
          padding: "12 0"
        }
      }));
    }

    return separatedList.build({
      items: items,
      style: {
        padding: "0 20"
      }
    });
  }
}