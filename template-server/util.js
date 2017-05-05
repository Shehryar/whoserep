
module.exports = {

	getUseCases: function(completion) {
  		fileUtil.getContentsOfFile(useCasesFilepath, function(code, data, contentType, err) {
    		completion(data.toString());
  		});
	}
};