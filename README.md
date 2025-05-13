# Divvy

A chore sharing app that aims to eliminates conflicts over chores serving as a neutral mediator that tracks chore schedules, assigns tasks, and reminds roommates when they haven’t done their work. With special features like swapping chores and dividing roomates into chore groups.

Build in Flutter, using Firebase as database and connected to backend via Flask.

## Backend
We have two repos one for backend and this on for frontend in order to run the app with connection to backend you must set up and run the backend repo which is located at https://github.com/Arkanous/DivvyBackend. 

## Table of Contents
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Build and Run](#build-and-run)
* [Testing](#testing)
* [Code Structure](#code-structure)


## Prerequisites
Before you begin, ensure you have the following installed:
The frontend is written in a combination of Flutter and Dart:
* **Flutter 3.32** 
* **Dart 3.8+** 
- This will required main channel version of flutter

## Installation
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
2. Choose device you wish to run app on, (i.e. physical device connected, emulator, webpage, or desktop app)
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

## Code Structure
The bulk of the source code resides in lib folder while the rest are the tests which are contained in the test directory.
* **firebase**: Contains code need for firebase authentication
* **models**: Contains code for creating object sturctures used around app such as chore (which describes a chore), member (which describes a user), and subgroup (which discribes a group of users assigned to certain chores) along with divvy_theme.dart which is the theme file used to style the app.
* **provider**: Contains the provider used across the app to keep the screens in sync and allows for modification to data and communication with backend
* **screens**: Contains the code to create each of the screen with each file linked to a specific screen.
* **util**: Contains addition functionality for app like date_funcs.dart which handled date formating and generating automatic assignment of chores and dialogs.dart which creates create skeletons of dialogs used around the app for user interaction.
* **widgets**: Contains custom widget pages that are used to create certain aspects of the app that share styling and structure.
* **divvy_navigation.dart**: Handles bottom navigation bar that connects main pages.
* **firebase_options.dart**: Contains the necessary information for connecting to firebase.
* **main.dart**: Creates the main function and runs the app.
* **test (outside of lib)**: Contains all test files and is run with CI through GitHub actions.
* **.github\workflows\flutter-ci.yaml**: Configures GitHub actions to both run tests and build app in both IOS and Andorid when pulling from main.

