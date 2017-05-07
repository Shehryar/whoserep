const fs = require('fs');
const path = require('path');

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

module.exports = {

	/**
	completion format: (code: 200, data: {...}, contentType: '', err: '')
	*/
	getContentsOfFile: function(pathname, completion) {

		fs.exists(pathname, function (exist) {

			// Return 404 if the file is not found.
			if (!exist) {
				completion(404, null, null, 'File ' + pathname + ' not found!');
				return 
			}

			// If is a directory, then look for index.html
			if (fs.statSync(pathname).isDirectory()) {
				pathname += '/index.html';
			}
			
			// Read the file
			fs.readFile(pathname, function(err, data){
				if (err){
					completion(500, null, null, 'Error reading the file: ' + err);
				} else {
					// Extract the content type from the pathname.
					const ext = path.parse(pathname).ext;
					const contentMimeType = mimeType[ext] || 'text/plain';

					completion(200, data, contentMimeType, null);
				}
			});
		});
	},

	/**
	completion format: (code: 200, files: [...], err: '')
	*/
	getFilesInDirectory: function(directory, extension, stripExtension, completion) {
		fs.readdir(directory, (err, files) => {
			if (err) {
				completion(500, null, 'Unable to find directory.');
				return;
			}

			let fileNames = []
			files.forEach(file => {
				if (!extension || ~file.indexOf(extension)) {
					if (stripExtension) {
						fileNames.push(file.split('.')[0]);
					} else {
						fileNames.push(file);
					}
				}
			});
			completion(200, fileNames, null);
		});
	},

	writeToFile: function(filepath, data, completion) {
		fs.writeFile(filepath, data, function(err) {
			completion(err);
		});
	},

	/**
	 MUSTACHE
	 */
	getMustacheTemplate: function(pathname, completion) {
		this.getContentsOfFile(pathname, function(code, data, contentType, err) {
			if (err) {
				completion(code, null, err);
				return
			}

			try {
				var template = String(data);
			} catch (e) {
				console.log('Error parsing mustache template: ' + pathname);
				console.log(e);

				completion(500, null, 'Unable to parse template');
				return;				
			}

			completion(code, template, err);
		});
	},
};