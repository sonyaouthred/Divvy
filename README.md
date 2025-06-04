# Divvy

# User Documentation

Divvy is a chore sharing app that aims to eliminates conflicts over chores serving as a neutral mediator that tracks chore schedules, assigns tasks, and reminds roommates when they haven’t done their work. Divvy includes special features like swapping chores and dividing roomates into chore groups.

## Installation

The end target for this app is to be deployed to physical devices over the App Store or Google Play Store. For now, it is necessary to download the code repository and run it on a simulator (right now, we recommend iOS as we have tested on it the most). The final release build will be launched via TestFlight, so it can be installed with just a link. Please refer to the [Build Instructions](#build-instructions) and the [Build and Run](#build-and-run) sections of the developer documentation below for information on how to run the repository (be sure to refer to the [Setting up the Backend](#setting-up-the-backend) section to run the backend server as well). This section will explain the system requirements.

## How To Use

While you can create your own house with roommates right now, we have a few fake accounts you can try out to see a house with some chores populated. All of the below emails work with the password: divvydemo.

- natasha@divvy.com
- iamironman@divvy.com
- nickfury@divvy.com
- peter@divvy.com

Basic path:
After downloading the app, you have several options. You can either sign in with one of the dummy accounts we have above, or you can press "Create Account" to create a new account. This will then prompt you to create a house. Once you've created a house, you will be redirected to your home screen.

Once your house has been created, you can invite people by having them download the app and then sharing your house's join code with them (found in House screen -> House Settings -> Join Code). Once you have a house (with or without roommates), you can create chores, subgroups, and more. Creating a chore can be done on the Chore screen. Subgroups can be created on the House screen. Once a chore is created, you can edit it or delete it. You can't change the frequency of a chore that has already been created, though.

By tapping on the Calendar screen, you can see a day-by-day breakdown of the chores that are assigned to you. You can also select a custom date. Overdue chores are displayed prominently on your dashboard, and you can easily mark them as completed by tapping the button on the bottom of the page that opens when you tap on the overdue chore.

You can tap on any user's profile picture to see their information and upcoming chores.

If you want to swap a chore, you can click the three dots at the top right (when you have the chore's instance screen open) and tap "Swap chore". This will open it up to all other users in the house. If they want to swap with you, they can see the open swap on their dashboard and then select a chore they want to offer to you. Once they have selected a chore, it will show up on your dashboard that "So-and-so offered to swap Y for X". You will easily be able to see the chore they offered, and hit either "accept" or "reject". Once you accept it, the chore assignments will be swapped and your calendar/schedule will be updated. If you reject it, the swap will be set to open again, and other members of the house will again be able to offer other chores for it.
**Important note on swaps**: You can only swap two chores of the same type. E.g. Upstairs bathroom on 5/25/25 can only be swapped for another Upstairs Bathroom assignment on a different (later) date.

## Bug Tracking

All of our current bugs are located on our [issue page](https://github.com/sonyaouthred/Divvy/issues). We are not currently aware of any major bugs.

Please report any bugs found to our issue page (above). While we do not have a template set up (we need GitHub pro??), please use the following format:

**Clear, succinct title that mentions the data/functions corrupted/ineffective**

- <ins>Your information:</ins> Explanation of what machine you are running the app on (iOS/android) and the installed OS.
- <ins>Location:</ins> where are you encountering the bug? This should be just a few words. Dashboard? House page?
- <ins>Frequency:</ins> Description of the "repeatability" of the bug - can you trigger it every time you try to? Does it seem to be sporadic?
- <ins>Steps to reproduce:</ins> If highly repeatable, describe the exact steps necessary to reproduce it.
- <ins>Problem</ins>: Explain the desired result of your actions versus the actual results. Prefer facts over observations.

# Developer Documentation

## Backend

In order to run the app, you must run our flask server on your device. The repository for the backend is at: https://github.com/Arkanous/DivvyBackend. Please refer to the backend repo on how to run the server.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Build Instructions](#build-instructions)
- [Build and Run](#build-and-run)
- [Setting up the Backend](#setting-up-the-backend)
- [Testing](#testing)
- [Code Structure/Layout](#code-structure)
- [Use Case](#use-case)

## Prerequisites

There are no prerequisites for this app. You will need flutter and dart installed, but this can be achieved through our build instructions.

## Build Instructions

1. Install Flutter

- Link to Flutter Documentation on installation process (https://docs.flutter.dev/get-started/install)
- Follow process for device you intend to use.
- This was done through Visual Studio Code plugin for our developers.
- Note in order to run on either Andorid you will also need to install Andorid Studio to run on IOS you will need to install XCode

2. Switch to main channel and upgrade to ensure correct version of dart

```
flutter channel main
flutter upgrade
```

3. Clone repo

```
git clone https://github.com/sonyaouthred/Divvy.git
cd <your_repository_directory>
```

4. Update dependecies

```
dart pub get
flutter pub get
```

For Mac users:

- If you want to run the app on an iPhone simulator, you should download & install XCode. If you wish to only run on MacOS or Chrome, this is not necessary.
- You will likely be prompted at some point to install Android Studio - if you do not (which is ok), your android folder will always be red/show an error. This is OK!!!! It will not impact your ability to run on other target destinations.

For Windows users:

- You should download Android Studio to run the app on an Android emulator.

## Build and Run

1. Either run via run button in top right corner or through command line

```
flutter run
```

2. Choose device you wish to run app on, (i.e. physical device connected, emulator, webpage, or desktop app). For the beta release, we recommend using Chrome.

- If running via button in VSC you will be prompted up top
- If through the command line you will be prompted similar to this:

```
Connected devices:
Windows (desktop) • windows • windows-x64    • Microsoft Windows [Version 10.0.26100.3775]
Chrome (web)      • chrome  • web-javascript • Google Chrome 136.0.7103.93
Edge (web)        • edge    • web-javascript • Microsoft Edge 136.0.3240.64
[1]: Windows (windows)
[2]: Chrome (chrome)
[3]: Edge (edge)
Please choose one (or "q" to quit):
```

That lists all connected device you can choose from.
Note the app is design for phone size screen so when running on chrome or other webpages please shrink down size of window otherwise could be some formatting issues.

We can guarantee the app will run as expected on iPhone simulators, Android emulators, and MacOS/Windows. Some of our devs have found Chrome to be inconsistent and a bit tempremental with the app, which we do not intend to fix because the app is not meant to be a web app.

**Important**: TL;DR: Run on Chrome at your own risk. We _do not_ recommend this. It will work, but the app is intended for a mobile device.

We can guarantee the app will run as expected on iPhone simulators, Android emulators, and MacOS/Windows. Some of our devs have found Chrome to be inconsistent and a bit tempremental with the app, which we do not intend to fix because the app is not meant to be a web app.

**Important**: TL;DR: Run on Chrome at your own risk. We _do not_ recommend this. It will work, but the app is intended for a mobile device.

The app will prompt you to sign in. Please refer to the [How to Use](#how-to-use) section above for sample logins.

## Setting up the Backend

1.  **Please see the backend repository for instructions on setting up the backend:** https://github.com/Arkanous/DivvyBackend
2.  This will enable you to make requests from the database via the Flask server.
3.  Note that with the current release, the Flask server and the frontend need to be running on the same machine. This will change. For now, make sure the Flask server is running on the same machine as the Flutter app.

## Testing

1. Running via command line

```
flutter test
```

To run a group of test or single test use:

```
flutter test --name theGroupName
flutter test --name theTestName
```

2. To run via VSC, navigate to the tests inside of the test folder, click the run buttons along the left hand side to run either specific tests or a group of tests

3. In order to run the server tests, move the server_test.dart file into the /test folder and follow the above instructions. This will only pass when you also have the backend server running on your local device.

4. If you wish to add new tests, simply create a dart file in the test/ folder. Be aware that all tests in that directory will automatically be run by the CI. The name of the file should represent what it is testing, followed by "\_test.dart". Tests should be placed in group()s that are relevant to what is being tested, and each individual test() should be testing a specific use case/desired output. Test()s should have descriptive names that represent the input and desired output.

**Test Formatting**:
If a test is solely testing frontend it should reside in the test folder if it is testing backend and frontend it should reside in the server_tests folder. Each test should have a helpful test description for future debugging and if creating a new group of test the group itself should similarly have a helpful description. If creating any chores, members, subgroups, house etc. for testing purpose please delete them at the end of the test.

**IMPORTANT NOTE ON TESTS**: If you run the dates tests on your local computer, it is likely that one or more tests will fail. These tests fail on our local machines, but pass the GitHub CI. If we modify them so that they pass on our local machines, they fail on the GitHub CI. We are not sure why, but if you encounter this, don't worry! We know. So annoying.

## Continuous Integration Testing
Our github repo uses Github Action to preform continuous intregration testing and to automate building. It currently triggers everytime someone pushes or pulls from the main branch, or if someone pushes with the tag **v** which we use to tag the build number of different versions. There are three phases it completes the Run Flutter Test, Build Flutter app (IOS), Build Flutter App (Android). The first phase Run Flutter Test sets up flutter with all the requirments and then runs all the test located in the **test** folder, it will then report which test fail and pass. Note, if there is any failing tests in this first phase it doesn't attempt the other two. The second and third phase both attempt to build app in IOS and Android respectivly as report if the build was successful.

### Where to find new and previous runs?
All reports from Github Actions are available in the Github Repo website (https://github.com/sonyaouthred/Divvy) under the tab labeled Actions (found along the top bar next to Discussions and Projects). All previous workflows are displayed on the page with the commit number notated and what triggered the workflow (i.e. Commit 345636 pushed by sonyaouthred or Pull request #12 opened by sonyaouthred). When clicking on a specific work flow it will open up a details page which shows actions process in a diagram where you can open different segements to see what exactly failed whether it be the linter in the Run Flutter Test or a portion of the builds.

The configuration for our Github Actions is located in **github\workflows\flutter-ci.yaml**.

## Release Builds

In order to create a release build, you must attach a tag to your github commit/merge that starts with **v**. In order to ensure correct numbering, make the tag the next version number. As a sanity check, please make sure to build the app one last time before you push! Often we fix minor things just before a release that accidentally breaks something. Building the app & running on a simulator should be the absolute last thing you do before pushing.

Testflight can also have different release builds created however due to premission that is a feature that can only be preform by the team directly.

## Code Structure

The bulk of the source code resides in lib folder while the rest are the tests which are contained in the test directory.

Here is a helpful diagram of the various files and how they fit together:

![repo structure](assets/repo_structure.png?raw=true "Repository Structure")

Divvy/ 
├── .github/workflows/flutter-ci.yaml # Configures GitHub actions to both run tests and build app in both IOS and Android when pulling from main.
├── android/ # Handles the build requirements, permissions, assets and code need to build app in android
├── assets/ # Contains any images locally used for the app. 
├── ios/ # Handles the build requirements, permissions, assets, and code need to build the app in IOS
├── lib/  
| ├── firebase/  # Contains for firebase authentication services
| ├── models/  # Contains code for creating object sturctures used around app such as chore, comment, house, member, subgroup, swap, and user. Along with divvy_theme.dart which is color theme file for the app.
| ├── providers/ # Contains the provider for entire app which helps manage state, allows for modificaiton to data, and communication with backend.
| ├── screens/  # Contains all the code for each of the screen with a screen per file.
| ├── util/  # Contains addition functionality for app like date_funcs.dart which handled date formating and generating automatic assignment of chores and dialogs.dart which creates create skeletons of dialogs used around the app for user interaction. Also contains the code for accessing the server and posting/fetching requests
| ├── widgets/ # Contains code for custom widgets that provide a template to reuse repeated widgets for styling and structure.
| ├── divvy_navigation.dart # Code for handling the navigation bar at the bottom of the app
| ├── firebase_options.dart # Specifications for connecting firebase to flutter app
| ├── main.dart # Holds codes that starts off the app, user login, and initializes aspects of the app
├── linux/ # Handles the build requirement, permissions, assets and code to build the app on linux
├── macos/ # Handles the build requirement, permissions, assets and code need to build the app on mac
├── server-tests/ # Contains a file with tests for the server connection. This is not part of the CI pipeline because the CI does not run the server locally. Until the server operates as a separate entity, this will not be part of CI.
├── test/ # Holds all the tests for the frontend that get run with CI through GitHub Actions
├── web/ # Handles the build requirement, permissions, assets and code to build the app on web, like chrome
├── windows/ # Handles the build requirement, permissions, assets and code need to build the app on window
├── .gitignore # Files and directory to be ignored by Git
├── .README.md # General overview documentation and developer guideline
├── .USERMANUAL.md # User guideline for running and installing the app
├── .pubspec.yaml # List of all the dependencies needed for flutter

