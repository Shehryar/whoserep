ASAPP iOS SDK
=============

Framework Integration
---------------------

### Add ASAPP.framework to Embedded Binaries

Add ASAPP.framework to the desired location in your project's directory.
After opening Xcode, drag-and-drop ASAPP.framework into *Embedded
Binaries* in the *General* settings of your project's target. Xcode
should now display ASAPP.framework under both *Embedded Binaries* and
*Linked Frameworks and Libraries*.

### Always Embed Swift Standard Libraries → Yes

Under your target's "Build Settings", set "Always Embed Swift Standard
Libraries" to "Yes". This is necessary because the ASAPP iOS SDK is
built using Swift.

### User-Defined Setting *SWIFT\_VERSION* → 3.2 or 4

This should not be required for most projects, but if you have used an
older version of Swift in your project, you may need to add a
user-defined setting to avoid any compiler issues. Go to the "Build
Settings" of your target, scroll to "User-Defined" near the bottom, and
add a new key "SWIFT\_VERSION" with value "3.2" or "4".

### Add NSPhotoLibraryUsageDescription/NSCameraUsageDescription to Info.plist

As of iOS 10, Apple requires a description for why your app uses the
photo library and/or camera. Since our SDK has features using the photo
library and the camera, your Info.plist will need brief descriptions
("In-app chat allows users to upload images") for both of these. If
accessing the Info.plist via Xcode, the keys are "Privacy - Camera Usage
Description" and "Privacy - Photo Library Usage Description". If
accessing your Info.plist via a text editor, the keys are
"NSPhotoLibraryUsageDescription" and "NSCameraUsageDescription".

### Add Custom Run Script to Build Phases

ASAPP.framework is distributed as a fat framework, meaning that it is
built to run on all devices and simulators. In order to upload your app
to the App Store, you will need to strip the ASAPP.framework of the
information used to build it for the iOS Simulator. If you are
incorporating other custom frameworks, you may already have a run script
phase that handles this. However, if not, we have included a simple run
script that will take care of this for you.

Under the "Build Phases" tab of your target, click the plus button to
add a "New Run Script Phase". Make sure the "Shell" value is "/bin/sh".
Copy-paste the contents of the asapp\_run\_script.sh file into the
script area.

SDK Usage
---------

### Initialize [ASAPP](Classes/ASAPP.html) with [ASAPPConfig](Classes/ASAPPConfig.html)

    let config = ASAPPConfig(appId: appId,
                             apiHostName: apiHostName,
                             clientSecret: clientSecret)

    ASAPP.initialize(with: config)

### Set [User](Classes/ASAPPUser.html)

    let user = ASAPPUser(userIdentifier: userIdentifier,
                         requestContextProvider: requestContextProvider,
                         userLoginHandler: userLoginHandler)

    ASAPP.user = user

### Customize [Styles](Classes/ASAPPStyles.html)

    var styles = ASAPPStyles.stylesForAppId(appId)

    ASAPP.styles = styles

### Customize Styles with a [Font Family](Classes/ASAPPFontFamily.html)

    let avenirNext = ASAPPFontFamily(
                light: UIFont(name: "AvenirNext-Regular", size: 16)!,
                regular: UIFont(name: "AvenirNext-Medium", size: 16)!,
                medium: UIFont(name: "AvenirNext-DemiBold", size: 16)!,
                bold: UIFont(name: "AvenirNext-Bold", size: 16)!)

    ASAPP.styles = ASAPPStyles.stylesForAppId(appId, fontFamily: avenirNext)

### Customize [Text Styles](Classes/ASAPPTextStyles.html)

    ASAPP.styles.textStyles.navTitle = ASAPPTextStyle(font: avenirNext.bold, size: 18, letterSpacing: 0, color: .white)

### Customize [Strings](Classes/ASAPPStrings.html)

    ASAPP.strings.chatTitle = "Demo Chat"
    ASAPP.strings.predictiveTitle = "Demo Chat"
    ASAPP.strings.chatAskNavBarButton = "Ask"
    ASAPP.strings.predictiveBackToChatButton = "History"
    ASAPP.strings.chatEndChatNavBarButton = "End Chat"

### Customize Title [Views](Classes/ASAPPViews.html)

    ASAPP.views.chatTitle = UIImageView(image: UIImage(named: "chat-logo"))
    ASAPP.views.predictiveTitle = UIImageView(image: UIImage(named: "help-logo"))

### Launch Chat

There are [two methods](Classes/ASAPP.html#/Entering%20Chat) for creating a chat view controller. Which method
you should call is determined by how you display the view controller.

If the chat is being displayed because the user tapped a push
notification, the notification's userInfo dictionary should be passed in
when creating the chat view controller.

#### Presentation (Modal)

    let viewController = ASAPP.createChatViewControllerForPushing(fromNotificationWith: nil, 
                                                                  appCallbackHandler: deepLinkHandler)

    present(viewController, animated: true, completion: nil)

#### Push (Navigation Controller)

    let viewController = ASAPP.createChatViewControllerForPresenting(fromNotificationWith: nil, 
                                                                     appCallbackHandler: deepLinkHandler)

    present(viewController, animated: true, completion: nil)

### Push Notifications

ASAPP can send your users push notifications when they receive a message
but are not viewing their chat. When your application receives the push
notification, you can [ask the ASAPP SDK](Classes/ASAPP.html#/Push%20Notifications) if the push notification is
intended to open chat.

    // In your application's delegate

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {    
        
        if ASAPP.canHandleNotification(with: userInfo) {
            
            // At this point, you should show the chat view controller, passing in the
            //    userInfo dictionary when creating the view controller.
            // *Note: You should make sure the chat view controller is not already visible
            //    before displaying (even though this shouldn't actually happen).
        }
    }

Run-Script for Stripping Unused Frameworks
------------------------------------------

    APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

    # This script loops through the frameworks embedded in the application and
    # removes unused architectures.
    find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
    do
    FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
    FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
    echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

    EXTRACTED_ARCHS=()

    for ARCH in $ARCHS
    do
    echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
    lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
    EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
    done

    echo "Merging extracted architectures: ${ARCHS}"
    lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
    rm "${EXTRACTED_ARCHS[@]}"

    echo "Replacing original executable with thinned version"
    rm "$FRAMEWORK_EXECUTABLE_PATH"
    mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"

    done
