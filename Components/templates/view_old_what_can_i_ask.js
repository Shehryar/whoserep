var _ = require('../components/all');

module.exports = {
  build: function() {
  	return _.componentView.build({
  		styles: {
  			block: {
  				align: "fill",
  				textAlign: "center",
  				textType: "body",
  				marginBottom: 16

  			}
  		},
  		body: _.stackView.build({
	    	style: {
	    		padding: 20
	    	},
	    	items: [
	    		_.label.build({
	    			text: "Need help paying your bill? Try asking \"How do I make a payment?\"",
	    			class: "block",
	    		}),
	    		_.label.build({
	    			text: "Having an issue with your internet? How about \"My internet is slow.\"",
	    			class: "block"
	    		}),
	    		_.label.build({
	    			text: "Customers also commonly ask about login credentials, channel lineup, or on demand features.",
	    			class: "block",
	    			style: {
	    				marginBottom: 0
	    			}
	    		})
	    	]
	    })
  	}); 
  }
}