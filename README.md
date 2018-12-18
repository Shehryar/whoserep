ASAPP - iOS
===========

© 2018 ASAPP Inc, all rights reserved.

Organization
------------

```
.
├── SDK             Chat SDK
├── fastlane        fastlane configuration files
├── package         Directory containing docs, the built framework, and example projects that is delivered to partners
├── scripts         Utility scripts
```

Running the test app locally
---------------

### Pre-requisites

Program | Version
--------|---------
Xcode   | 10.1

### Steps

1. Open `SDK/ASAPP.xcworkspace`
1. Select *ASAPPTest* from the schemes dropdown menu (near the stop button in the upper-left hand corner)
1. Select the device or simulator you'd like to to test on using the dropdown menu next to the scheme you just selected
1. Press the play button to build and run the application


Generating Component UI layout snapshots
---------------------------

Run `scripts/snapshots.sh`. It will open `SDK/Tests/Component UI Layout Tests`, validate existing snapshot images, and record snapshots for any `.json` files in the directory describing a [Component View container](https://asappinc.atlassian.net/wiki/spaces/EN/pages/26559024/Component+View) or a [Chat Message](https://asappinc.atlassian.net/wiki/spaces/EN/pages/26561197/Chat+Message) that lack a corresponding snapshot image file.

To generate a snapshot for a new layout, add the `.json` file to the `SDK/Tests/Component UI Layout Tests` directory and run `scripts/snapshots.sh` again.

Note that when a snapshot is generated for a new `.json` file, the test runner will report a failure—this is expected. It will report a success if you run the script again once the snapshot exists.


Development, QA, and release process
------------------------------------

We develop, test, and build using Xcode 10.1.

Loosely following [GitFlow](http://nvie.com/posts/a-successful-git-branching-model/), `develop` is the default branch. We merge `develop` into `staging` to prepare a release candidate. Once a release candidate has been approved, `staging` will be merged into `master`.

`staging` is built automatically by [CircleCI](https://circleci.com/gh/ASAPPinc/ASAPP-iOS) using [fastlane](https://fastlane.tools/) and distributed using Crashlytics/Fabric. The build number is automatically incremented. The version string is updated based on the pull request title.

1. Make a [pull request from `develop` to `staging`](https://github.com/ASAPPinc/chat-sdk-ios/compare/staging...develop?expand=1). We follow [SemVer](https://semver.org/) to define our versions. To increment the _patch_, _minor_, or _major_ versions, include "patch", "minor", or "major", respectively, in the pull request title. If none of these keywords are present in the title, the version will not be incremented.
1. On every commit to `staging`, our CircleCI workflow will check and update the version string, run tests, check that the public API is fully documented, and hold the release candidate for approval. Notifications will be sent to _#chat-sdk-ios-builds_ in Slack.
1. Unpause the `rc-approval` job to distribute a release candidate via Fabric.
1. Wait for QA approval. If changes need to be made, push changes or merge a pull request into `staging` again.
1. Unpause the `release-approval` job to archive the framework, tag the commit, create a GitHub release, and merge to master and develop. If there are conflicts, the channel will be notified.
1. Download `ASAPP iOS Framework X.Y.Z.zip` from either the CircleCI job or the GitHub release and upload it to Google Drive. Alert the relevant deployment manager.


Manually distributing a beta build of the test app (for QA)
-----------------------------------------------------------

### Pre-requisites

Program   | Version
----------|---------
ruby      | 2.4.5
[bundler](https://github.com/bundler/bundler)   | 1.16.2
[fastlane](https://github.com/fastlane/fastlane)  | 2.101.1

#### Note

It is recommended to manage your Ruby versions with [`rbenv`](https://github.com/rbenv/rbenv). To make sure Ruby 2.4.5 is installed, first install `rbenv`, install Ruby 2.4.5, and then select it globally. You may find [`rbenv-installer` and `rbenv-doctor`](https://github.com/rbenv/rbenv-installer#rbenv-doctor) helpful.

### Setup

1. `sudo gem install bundler`
1. `bundle update`
1. Add two environment variables to your `~/.bash_profile`: `CRASHLYTICS_API_TOKEN` and `CRASHLYTICS_BUILD_SECRET`. The values can be found in [Fabric's organization settings](https://fabric.io/settings/organizations/579a7fee8b15da79ab000067).
```
export CRASHLYTICS_API_TOKEN="fooooooo"
export CRASHLYTICS_BUILD_SECRET="baaaaaar"
```

### Steps for distributing a beta build

1. `bundle exec fastlane beta`

The _beta_ lane is configured to distribute a build to the "ASAPP iOS Dev" group. To view and configure groups, go to [Fabric](https://www.fabric.io/asapp/ios/apps/com.asappinc.testapp/beta/releases/latest) and click "Manage Groups" under "Tools" in the left-hand menu.


Generating API reference pages from documentation comments
----------------------------------------------------------

### Pre-requisites

Program   | Version
----------|---------
ruby      | 2.4.5
[bundler](https://github.com/bundler/bundler)   | 1.16.2
[jazzy](https://github.com/realm/jazzy)  | 0.9.3

### Running `jazzy`

You may need to run `bundle update` as above.

```
scripts/generate_docs.sh
```

The reference website can be found at `package/docs/swift/index.html`.

Running tests
----------------------------------------------------------

### Pre-requisites

1. `brew install carthage`
2. `cd SDK && carthage bootstrap`

### Steps

1. Select either `All Tests` or `Fast Tests`
2. Select iPhone SE as target device
3. Run tests

Running the Objective-C example project
----------------------------------------------------------

1. Open Xcode 10.1
2. Archive the *Aggregate* scheme for a *Generic iOS Device*. The framework will be updated automatically.
3. Open and run the example Objective-C project at `/package/Objective-C Example/ASAPPChatDemoObjc.xcodeproj`
