const http = require('http');
const Router = require('node-router');
const router = Router();
let route = router.push;
const fileUtil = require('./file-util');


/**
 Constants
 */

const PORT = process.argv[2] || 9000;
const JSON_DIRECTORY = './json/';
const USE_CASES_FILEPATH = './use-cases.json';


/** 
 Routing 
 */

// Request Logging
route(function (req, res, next) {
  console.log('----------------------------------------');
  console.log(req.method + ' ' + req.path + ' ' + JSON.stringify(req.query));
  next();
});

route('GET', '/components', function(req, res, next) {
  fileUtil.getFilesInDirectory(JSON_DIRECTORY, true, function(code, fileNames, err) {
    res.send(code, fileNames || err);
  });
});

route('GET', '/use_cases', function(req, res, next) {
  fileUtil.getContentsOfFile(USE_CASES_FILEPATH, function(code, data, contentType, err) {
    res.send(code, data.toString());
  });
});

// Fallback to fetching filename
route( function (req, res, next) {
  const pathname = JSON_DIRECTORY + req.path
  fileUtil.getContentsOfFile(pathname, function(code, data, contentType, err) {
    if (code != 200) {
      res.send(code, err);
    } else {
      res.setHeader('Content-type', contentType);
      res.end(data);
    }
  });
});

// Request not found
route(function (req, res, next) {
  console.log('404');
  res.send(404, 'Custom Not Found');
});


/**
 Server
 */

// Launch the server
let server = http.createServer(router).listen(PORT);
console.log('Server listening on port: ' + PORT);
