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

Before you begin, ensure you have the following installed:
The frontend is written in a combination of Flutter and Dart:

- **Flutter 3.32**
- **Dart 3.8+**

* This will required main channel version of flutter

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
git clone <your_repository_url>
cd <your_repository_directory>
```

4. Update dependecies

```
dart pub get
flutter pub get
```

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

4. If you wish to add new tests, simply create a dart file in the test/ folder. Be aware that all tests in that directory will automatically be run by the CI. Follow the standard flutter testing syntax, as modeled by the other test files.

## Release Builds

In order to create a release build, you must attach a tag to your github commit/merge that starts with **v**. In order to ensure correct numbering, make the tag the next version number. As a sanity check, please make sure to build the app one last time before you push! Often we fix minor things just before a release that accidentally breaks something. Building the app & running on a simulator should be the absolute last thing you do before pushing.

## Code Structure

The bulk of the source code resides in lib folder while the rest are the tests which are contained in the test directory.

- **android/ios/mac/web/windows**: These folders contain the requisite assets involved with running the app on either android, ios, mac, or web.
- **assets**: This stores any images locally used for the app. For now, it just stores a dummy user profile image.
- **firebase**: Contains code need for firebase authentication
- **models**: Contains code for creating object sturctures used around app such as chore (which describes a chore), member (which describes a user), and subgroup (which discribes a group of users assigned to certain chores) along with divvy_theme.dart which is the theme file used to style the app.
- **provider**: Contains the provider used across the app to keep the screens in sync and allows for modification to data and communication with backend
- **screens**: Contains the code to create each of the screen with each file linked to a specific screen.
- **util**: Contains addition functionality for app like date_funcs.dart which handled date formating and generating automatic assignment of chores and dialogs.dart which creates create skeletons of dialogs used around the app for user interaction. Also contains the code for accessing the server and posting/fetching requests
- **widgets**: Contains custom widget pages that are used to create certain aspects of the app that share styling and structure.
- **divvy_navigation.dart**: Handles bottom navigation bar that connects main pages.
- **firebase_options.dart**: Contains the necessary information for connecting to firebase.
- **main.dart**: Creates the main function and runs the app.
- **test (outside of lib)**: Contains all test files and is run with CI through GitHub actions.
- **server_test (outside of lib)**: Contains a file with tests for the server connection. This is not part of the CI pipeline because the CI does not run the server locally. Until the server operates as a separate entity, this will not be part of CI.
- **.github\workflows\flutter-ci.yaml**: Configures GitHub actions to both run tests and build app in both IOS and Andorid when pulling from main.
