var _ = require('../components/all');

module.exports = {
  build: function() {
  	return _.componentView.build({
  		styles: {
  			center: {
  				align: "fill",
  				textAlign: "center"
  			}
  		},
  		body: _.stackView.build({
	    	style: {
	    		padding: 20
	    	},
	    	items: [
	    		_.label.build({
	    			text: "$96.08*",
	    			class: "center",
	    			style: {
	    				textType: "header1",
	    				marginBottom: 4
	    			}
	    		}),
	    		_.label.build({
	    			text: "CURRENT BALANCE",
	    			class: "center",
	    			style: {
	    				textType: "subheader",
	    				marginBottom: 16
	    			}
	    		}),
	    		_.label.build({
	    			text: "Pay by 11/20/16",
	    			class: "center",
	    			style: {
	    				textType: "body",
	    				marginBottom: 12
	    			}
	    		}),
	    		_.separator.build(),
	    		_.label.build({
	    			text: "*Recent transactions may take a few days to reflect on your bill.",
	    			class: "center",
	    			style: {
	    				marginTop: 12,
	    				textType: "detail1"
	    			}
	    		})
	    	]
	    })
  	}); 
  }
}