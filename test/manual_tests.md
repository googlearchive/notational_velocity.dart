#nv.dart - Manual Tests

## WTF?

* We're waiting on [Chrome Driver](https://code.google.com/p/chromedriver/) to support automating custom elements - [bug 438](https://code.google.com/p/chromedriver/issues/detail?id=438).
* In the mean time, we need to document explicit user flows to track issues and ensure we have no regressions.
* We can dream of a day when these are all in code.

## How to "run" these...

* All of these tests assume the default setup.
* App opens with default three items.
    * About app
    * About Notational Velocity
    * Credits
    * How does this thing work?

## Tests

### 000 - New note - *passing*

__Actions__

* In search box, type new note title 'Test'
* Hit 'return'

__Expected Result__

* New note with title 'Test' is added to list
* New note with title 'Test' is selected in list
* Editor box is empty and has focus

### 001 - open existing note by search full title - *passing, regression test for #26*

__Actions__

* In search box, type existing note title 'About app'
* Hit 'return'

__Expected Result__

* 'About app' note is the only note in the list, and it's selected
* Edit box has focus, with content of 'About app' note

### 002 - open existing note by searching partial title - *passing, regression test for #27*

__Actions__

* In search box, type first part of existing note title 'about n'
    * Should see only 'About Notational Velocity' in list, selected
* Hit 'return'
    * 'About Notational Velocity' item is open in editor

#### 003 - search box should have focus on app load - *passing, regression for #34*

__Actions__

* Start the app
    * Should see that the search box has focus

#### 004 - incremental search does not update edit box if there is a previous best match *failing, issue #36*

* Type 'about ' (notice the space) in the search box
    * Two items in list: 'About app' and 'About Notational Velocity'
    * 'About app' is selected
    * Contents of 'About app' are in edit box
* Type the letter 'n'
    * One item in list 'About Notational Velocity', selected

__Expected Result__

*  Content of 'About Notational Velocity' should be in edit box
