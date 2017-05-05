const FileUtil = require('./file_util');
const Router = require('node-router');

const JSON_DIRECTORY = './json/';
const USE_CASES_FILEPATH = './use-cases.json';
const TEMPLATES_DIRECTORY = './templates';
const OUTPUT_DIRECTORY = './output';

const router = Router();
let route = router.push;

// Request Logging
route(function (req, res, next) {
  console.log('\n----------------------------------------');
  console.log(req.method + ' ' + req.path + ' ' + JSON.stringify(req.query));
  next();
});

route('GET', '/components', function(req, res, next) {
  FileUtil.getFilesInDirectory(JSON_DIRECTORY, true, function(code, fileNames, err) {
    res.send(code, fileNames || err);
  });
});

route('GET', '/use_cases', function(req, res, next) {
  FileUtil.getContentsOfFile(USE_CASES_FILEPATH, function(code, data, contentType, err) {
    res.send(code, data.toString());
  });
});

route('GET', '/use_case', function(req, res, next) {
  const id = req.query.id;
  if (!id) {
    res.send(400, 'id query parameter is required.');  
    return;
  }

  FileUtil.getContentsOfFile(USE_CASES_FILEPATH, function(code, data, contentType, err) {
    if (code != 200) {
      res.send(code, err);
      return;
    }

    const useCases = JSON.parse(data);
    if (!useCases) {
      res.send(500, 'Unable to parse use cases data');
      return;
    }

    var useCase = useCases[id];
    if (!useCase) {
      res.send(404, 'Unable to find use case with id: ' + id);
      return;
    } 

    // Fetch the template
    const templateName = useCase.template || id;
    const templateFilepath = TEMPLATES_DIRECTORY + '/' + templateName;
    console.log('  Fetching template at: ' + templateFilepath);
    try {
      var template = require(templateFilepath);
    } catch (err) {
      res.send(500 ,'Unable to locate template file.');
      return;
    }
    
    // Generate the JSON
    const templateOutput = template.build(data);
    const json = JSON.stringify(templateOutput);
    res.setHeader('Content-type', contentType);
    res.end(json);

    // Store output
    const outputFilepath = OUTPUT_DIRECTORY + '/' + id + '.json';
    const prettyJSON = JSON.stringify(templateOutput, null, 2);
    FileUtil.writeToFile(outputFilepath, prettyJSON, function(err) {
      if (!err) {
        console.log('  Saved output to: ' + outputFilepath);
      } else {
        console.log('  Unable to save output to: ' + outputFilepath);
        console.log(err);
      }
    });
  });
})

// Fallback to fetching filename
route( function (req, res, next) {
  const pathname = JSON_DIRECTORY + req.path
  FileUtil.getContentsOfFile(pathname, function(code, data, contentType, err) {
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

module.exports = { router: router };
