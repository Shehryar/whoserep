const http = require('http');
const url = require('url');
const fs = require('fs');
const path = require('path');
// you can pass the parameter in the command line. e.g. node static_server.js 3000
const port = process.argv[2] || 9000;

const jsonDirectory = './json/';

function getAvailableComponents(callback) {
  fs.readdir(jsonDirectory, (err, files) => {
    var components = []
    files.forEach(file => {
      if (~file.indexOf('.json')) {
        components.push(file.split('.json')[0]);
      }
    });
    callback(components);
  })
}




http.createServer(function (req, res) {

  console.log(`${req.method} ${req.url}`);

  if (req.method == 'GET' && req.url == '/components') {
    getAvailableComponents( function(components) {
      res.setHeader('Content-type', 'application/json');
      res.end(JSON.stringify(components));
    });
  } else { // Fall back to getting local file

    // maps file extention to MIME types
    const mimeType = {
      '.ico': 'image/x-icon',
      '.html': 'text/html',
      '.js': 'text/javascript',
      '.json': 'application/json',
      '.css': 'text/css',
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.wav': 'audio/wav',
      '.mp3': 'audio/mpeg',
      '.svg': 'image/svg+xml',
      '.pdf': 'application/pdf',
      '.doc': 'application/msword',
      '.eot': 'appliaction/vnd.ms-fontobject',
      '.ttf': 'aplication/font-sfnt'
    };

    // parse URL
    const parsedUrl = url.parse(req.url);
    // extract URL path
    let pathname = jsonDirectory + `${parsedUrl.pathname}`;
    fs.exists(pathname, function (exist) {
      if(!exist) {
        // if the file is not found, return 404
        res.statusCode = 404;
        res.end(`File ${pathname} not found!`);
        return;
      }
      // if is a directory, then look for index.html
      if (fs.statSync(pathname).isDirectory()) {
        pathname += '/index.html';
      }
      // read file from file system
      fs.readFile(pathname, function(err, data){
        if(err){
          res.statusCode = 500;
          res.end(`Error getting the file: ${err}.`);
        } else {
          // based on the URL path, extract the file extention. e.g. .js, .doc, ...
          const ext = path.parse(pathname).ext;
          // if the file is found, set Content-type and send data
          res.setHeader('Content-type', mimeType[ext] || 'text/plain' );
          res.end(data);
        }
      });
    });
  }
}).listen(parseInt(port));

console.log(`Server listening on port ${port}`);

getAvailableComponents(function(components) {
  console.log('\nAvailable Components:\n' + components.join('\n') + '\n');
});
