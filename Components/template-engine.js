
// TODO: pass the name of the template into the script

var template = require('./templates/1-2_message_talk_history');
var json = JSON.stringify(template.build(), null, 2);
console.log(json);
