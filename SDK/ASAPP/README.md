# ASAPP SRS SDK

----
## Installation: 

TODO


----
## Usage:

### Updating SRS.sharedInstance

Before using the SRS SDK to show an in-app chat experience, you will need to update the SRS class with information about your company and the user who is using the app. This must be done before accessing the sharedInstance on the SRS class

    let company = "CompanyABC" // Your company marker
    let userToken = "abc123" // Unique id for user using SRS
    let styles = ASAPPStyles()
    let environment = .Staging // Should change to .Production before releasing to the App Store

    // Can update styles object to use custom fonts/colors here

    SRS.update(company: company
               userToken: userToken
               authProvider: { () -> [String : AnyObject] in
                   // Return auth info
               },
               contextProvider: { () -> [String : AnyObject] in
                   // Return context info
               },
               callbackHandler: { (deepLink, data) in
                   // Handle deepLink passed back from SRS
               },
               styles: styles,
               environment: environment)

### Creating an SRS Button

Once SRS is updated with the required information, you may create an SRS button using the code below.  An SRSButton will handle presenting the chat view controller automatically.

    class YourViewController: UIViewController {
        var srsButton: ASAPPButton!

        override func viewDidLoad() {
            super.viewDidLoad()

           // Update SRS via SRS.update(...) before using the code below. 

            srsButton = SRS.sharedInstance().createNewButton(self)
            view.addSubview(srsButton)
        }

        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()

            // Update center of srsButton here.
            srsButton.center = CGPoint(...)
        }
    }


### Creating a ChatViewController Directly

If you decide to use your own custom button for triggering the presentation of the chat view controller, you may  do so with the  following sample code:

    // Update SRS via SRS.update(...)
    let chatViewController = SRS.sharedInstance().createNewChatViewController()
    present(chatViewController, animated: true, completion: nil)

Please note, the view controller created using createNewChatViewController() includes a navigation controller, so there is no need to embed the returned view controller in an additional navigation controller before presenting.



[MarkdownLivePreview](http://markdownlivepreview.com)


