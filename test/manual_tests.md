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

### 001 - open existing note with search - *passing, regression test for #26*

__Actions__

* In search box, type existing note title 'About app'
* Hit 'return'

__Expected Result__

* 'About app' note is the only note in the list, and it's selected
* Edit box has focus, with content of 'About app' note
