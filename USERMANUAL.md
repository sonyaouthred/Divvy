# Divvy

# User Manual

This is the user manual for Divvy that contains instruction on how to install, run, and use the app. Along with documentation on how to complete a bug report for future improvement.

## Description
**Divvy** is a chore sharing app designed for roommates to streamline their chore schedule as it tracks chores, divides up work, and reminds automatically.

## Table of Contents
- [How to Install](#how-to-install)
- [How to Use](#how-to-use)
- [Reporting Bugs](#reporting-bugs)
- [Notices](#notices)

## How to Install
 Our app is released on TestFlight for IPhone which allows for the app to be deployed on the phone like a regular app. To get the invitation link to please contact our member. 
 Note: Currently the app is only available in its release form the Iphone.

 Steps:
 1. Navigate to the IPhone App Store, search for TestFlight (it has a blue fan icon) and install the app.
 2. Then use the link in the invite email and open the link in the TestFlight app.
 3. Download the app as TestFlight prompts 
 4. Click the open button in order run the app from TestFlight

 Notes: The backend is current up and running on an Digital Ocean Droplet product using a Debian linux machine to run the server using gunicorn to run our flash server. This requires no set up on user side and is already connected the app.

## How to Use
The premise of the app is that everyone has an individual account and then joins a House which connects them with their roommates so that they can all share on chore calendar. Each chore with have an overarching description and information with each chore instance being a copy of that chore assigned to specific member at a specific time.
Note: A use can only be in one house at a time.

### Create an Account / Sign In
When first opening the app there is a login in page, if you already have an account you can login with your email and password. Otherwise there is a create account link below the login in forms. If you have already join the house you will be sent straight to your personal dashboard, if not you are sent page where you can join or create a house.

### Create, Join, Leave, and Delete a House
*Join*: Each house has a unique join code that allows for users to join to different houses which is located in the house setting page, under House Code, of the user already in the house. It is meant to be shared between roommates in person. This house code will be entered by a user to be granted permission into the house and will noted on their account and automatically sign them in the next time until they leave the house or someone deletes the house.
*Create*: To create a house the user will be asked to provide a name and once created their join code is automatically generated and found in their house settings page as they will be login to the house. 
*Delete*: The ability to delete a house is located in the house setting pages where it will prompt you for your password and confirm you course of action.
*Leave*: To leave a house navigate to your personal settings which has a leave house option.

### Navigation
The bottom bar in app serves as the main method of navigating through different screens. There are five main screens Calendar, Chores, Dashboard, House, and Settings.

*Calendar*: The calendar screens display the chores assigned to the user starting on current day with ability to select different days using a scrolling calendar bar.
*Chores*: Displays all of the overarching house chores and all subgroups and their chores that a user is apart of with the option to edit or add chores.
*Dashboard*: Displays any of the user's chores that are due that day, any upcoming chores over the week, any overdue chores, a leadboard of the house members based on their chore compeletion rate, and any swaps available at the bottom. 
*House*: Displays information pertaining to the house like listing all members, the current leaderboard, and the current subgroups. Allows user to modify subgroups, manage chores, navigate to specific member pages, and access the House Setting page.
*Settings*: This is the person settings page which allows the user to modify profile color, name, delete their account or the house and logout.

**Note**: For navigation on other pages they will typically contain a back button in the upper left corner and some have additional features that can be found by clicking the two dots in the upper right hand corner.

## Reporting Bugs
There are two options are avaible for bug reporting.
1. *Testflight Feedback Form*:
In the TestFlight app when running a app has two options open and feedback when clicking the feedback buttons allows for the user to add screenshots and report in writing any issues they find with the app.
2. *GitHub Issue Page*:
Located at [issue page](https://github.com/sonyaouthred/Divvy/issues). Please report any bugs found to our issue page here. While we do not have a template set up please use the following format for providing information:

**Clear, succinct title that mentions the data/functions corrupted/ineffective**

- <ins>Your information:</ins> Explanation of what machine you are running the app on (iOS/android) and the installed OS.
- <ins>Location:</ins> where are you encountering the bug? This should be just a few words. Dashboard? House page?
- <ins>Frequency:</ins> Description of the "repeatability" of the bug - can you trigger it every time you try to? Does it seem to be sporadic?
- <ins>Steps to reproduce:</ins> If highly repeatable, describe the exact steps necessary to reproduce it.
- <ins>Problem</ins>: Explain the desired result of your actions versus the actual results. Prefer facts over observations.

## Notices
**Lastest Build is v1.3.1 and TestFlight Build 3**