ASAPP - iOS
===========

© 2017 Asapp Inc, all rights reserved.

Organization
------------

```
.
├── SDK			Chat SDK
├── Provisioning	Provisioning profile and credentials
├── fastlane		fastlane configuration files
```

iOS Development
---------------

### Pre-requisites

Program | Version
--------|---------
Xcode   | 9.0

### Steps for running the apps

1. Open SDK/ASAPP.xcworkspace

1. Select 'ASAPPTest' from the schemes dropdown menu (near the stop button in the upper-left hand corner)

1. Select the device or simulator you'd like to to test on using the dropdown menu next to the scheme you just selected

1. Press the play button to build and run the application


Distributing a beta build of the test app (for QA)
--------------------------------------------------

### Pre-requisites

Program   | Version
----------|---------
ruby      | 2.4.2
[bundler](https://github.com/bundler/bundler)   | 1.15.4
[fastlane](https://github.com/fastlane/fastlane)  | 2.58.0

#### Note

It is recommended to manage your Ruby versions with [`rbenv`](https://github.com/rbenv/rbenv). To make sure Ruby 2.4.2 is installed, first install `rbenv`, install Ruby 2.4.2, and then select it globally. You may find [`rbenv-installer` and `rbenv-doctor`](https://github.com/rbenv/rbenv-installer#rbenv-doctor) helpful.

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

