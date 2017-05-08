const FileUtil = require('./file_util');
const Router = require('node-router');

const USE_CASES_DIRECTORY = './use_cases';
const MESSAGE_TEMPLATES_DIRECTORY = './templates/messages';
const OUTPUT_DIRECTORY = './output';
const JSON_DIRECTORY = './json/';


const router = Router();
let route = router.push;

// Request Logging
route(function (req, res, next) {
  console.log('\n----------------------------------------');
  console.log(req.method + ' ' + req.path + ' ' + JSON.stringify(req.query));
  next();
});

route('GET', '/use_cases', function(req, res, next) {
  FileUtil.getFilesInDirectory('./use_cases', '.json', true, function(code, files, err) {
    if (files) {
      console.log('  Found ' + files.length + ' use cases.');
    } else {
      console.log('  Unable to find use cases.');
      console.log(err);
    }
    res.send(code, files);
  });
});

route('GET', '/use_case', function(req, res, next) {
  const id = req.query.id;
  if (!id) {
    res.send(400, 'id query parameter is required.');  
    return;
  }

  const useCaseFilepath = USE_CASES_DIRECTORY + '/' + id + '.json';
  FileUtil.getContentsOfFile(useCaseFilepath, function(code, data, contentType, err) {
    if (code != 200) {
      res.send(code, err);
      return;
    }

    const useCase = JSON.parse(data);
    if (!useCase) {
      res.send(500, 'Unable to parse use cases data');
      return;
    }
    
    // Fetch the template
    const templateName = useCase.template || id;
    const templateFilepath = MESSAGE_TEMPLATES_DIRECTORY + '/' + templateName;

    console.log('  Fetching template at: ' + templateFilepath);
    try {
      var template = require(templateFilepath);
    } catch (err) {
      console.log('  Unable to locate template: ' + templateName);
      console.log(err);
      res.send(500, 'Unable to import template');
      return;

      // console.log('\n  Falling back on JSON');
      // const pathname = JSON_DIRECTORY + '/' + id + '.json';
      // FileUtil.getContentsOfFile(pathname, function(code, data, contentType, err) {
      //   if (code != 200) {
      //     res.send(code, err);
      //   } else {
      //     console.log('  Found json file');
      //     res.setHeader('Content-type', contentType);
      //     res.end(data);
      //   }
      // });
      // return;
    }
    
    // Generate the JSON
    // const templateOutput = template.build(useCase.data);
    try {
      var templateOutput = new template(useCase.data);  
    } catch (err) {
      console.log('  Unable to generate output from template: ' + templateName);
      console.log(err);
      res.send(500, 'Unable to generate output from template.');
      return;
    }
    
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

// Request not found
route(function (req, res, next) {
  console.log('404');
  res.send(404, 'Custom Not Found');
});

module.exports = { router: router };
