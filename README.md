ASAPP - iOS
===========

© 2017 Asapp Inc, all rights reserved.

Organization
------------

```
.
├── SDK   			Chat SDK
├── Provisioning   	Provisioning profile and credentials
└── template-server	NodeJS server for creating and testing UI files
```

iOS Development
---------------

### Pre-requisites

Program | Version
--------|---------
Xcode   | 8.2.1

### Steps for Running the Apps

1.	Open SDK/ASAPP.xcworkspace:

2.	Select 'ASAPPTest' from the schemes dropdown menu (near the stop button in the upper-left hand corner)

3.	Select the device or simulator you'd like to to test on:
	* Using the drop-down menu next to the scheme you just selected, you can select to test on a device connected to your computer or a simulator.

4.	Press the play button to build and run the application.

template-server
---------------

### Pre-requisites

Program | Version
--------|---------
NodeJS  | 7.7.3

### Steps for Running the Template Server

1.	Run the template server script from the home directory
	```bash
	$ ./run_template_server
	```

2.	Run the ComponentUI Previewer App
	* Open SDK/ASAPP.xcworkspace
	* Select 'ComponentUIPreviewer' from the schemes dropdown menu (upper-left).
	* Select a simulator to test on (this simulator can hit localhost; your device cannot).
	* Press the play button to build and run the application

3.  ... 