
var args = process.argv.slice(2);
var argsLength = args.length;
if (argsLength == 0) {
	console.log("Example Usage:");
	console.log("node template-builder.js [template filepath]");
	console.log("node template-builder.js [template filepath] [output directory]");
	console.log("node template-builder.js [template filepath] [output directory] [output filename]");
	return;
}

// Import the template
var templateFilepath = args[0];
try {
	var template = require("./" + templateFilepath);
} catch (err) {
	console.log("Unable to find template: " + templateFilepath);
	return;
}

// Build the template
var json = JSON.stringify(template.build(), null, 2);
if (argsLength == 1) {
	console.log(json);
	return;
}

// Create the output filepath
var outputDirectory = args[1];
var filename = null;
if (argsLength > 2) {
	filename = args[2];
} else {
	var pathComponents = templateFilepath.split(".json")[0].split("/");
	if (pathComponents.length > 1) {
		filename = pathComponents[pathComponents.length - 1] + ".json";
	} else {
		filename = pathComponents[0] + ".json";
	}
}
var outputFilePath = outputDirectory + "/" + filename;

// Write the json to the output file
var fs = require('fs');
var path = require('path');
fs.writeFile( path.join(__dirname, outputFilePath), json, function(err) {
    if (err) {
        return console.log(err);
    }

    console.log("Output saved to: " + outputFilePath);
});
