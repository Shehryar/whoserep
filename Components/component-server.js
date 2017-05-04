const http = require("http");
const url = require("url");
const fileUtil = require("./file-util");

// Can pass in the port number
const port = process.argv[2] || 9000;
const jsonDirectory = "./json/";
const useCasesFilepath = "./use-cases.json";

function getListOfJSONFiles(req, res) {
  fileUtil.getFilesInDirectory(jsonDirectory, true, function(code, fileNames, err) {
    if (code != 200) {
      res.statusCode = code;
      res.end(err);
    } else {
      res.setHeader("Content-type", "application/json");
      res.end(JSON.stringify(fileNames));
    }
  });
}

function getFileContents(req, res) {
  const pathname = jsonDirectory + url.parse(req.url).pathname;
  fileUtil.getContentsOfFile(pathname, function(code, data, contentType, err) {
    if (code != 200) {
      res.statusCode = code;
      res.end(err);
    } else {
      res.setHeader("Content-type", contentType);
      res.end(data);
    }
  });
}

function getUseCases(completion) {
  fileUtil.getContentsOfFile(useCasesFilepath, function(code, data, contentType, err) {
    completion(data.toString());
  });
}

// HTTP Server
http.createServer(function (req, res) {

  console.log(req.method + " " + req.url);

  if (req.method == "GET" && req.url == "/components") {
    getListOfJSONFiles(req, res);
  } else {
    getFileContents(req, res);
    
  }
}).listen(parseInt(port));

console.log("Server listening on port: " + port);

fileUtil.getFilesInDirectory(jsonDirectory, false, function(code, fileNames, err) {
  console.log((fileNames || []).length + " json files available.");
});

getUseCases( function(useCases) {
  console.log("Use Cases");
  console.log(useCases);
});
