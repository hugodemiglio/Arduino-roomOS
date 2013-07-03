Arduino RoomOS
--------------

Author: Hugo Demiglio

Contact: hugodemiglio (at) gmail (dot) com

Current stable version: 1.3.1

See this project at work: http://www.youtube.com/watch?v=aT9Iknwudso

### Recommended depencencies:
- Arduino IDE 0023
- Ruby 2.0.0p19 (2013-05-14 revision 40734)

Tested on Mac OS X 10.8.4 "Mountain Lion"

### How to use Ruby serial controller

```shell
  gem install bundler --no-ri --no-rdoc
  bundle install
  ruby update.rb
```

### Change log

###### 1.3.1 (2013-02-20) => current
- Add Gemfile to ruby controller (2013-07-02)
- Fixes a bug that did not allow the light to be turned on at 2:00 AM
- Fixes a temperature empty box on first startup
- Prevent a wrong temperature sensor response exceeds the limit of the screen
- Ruby script interface improvements

###### 1.3.0 (2013-02-04)
- Bluetooth (Serial) communication for system control
- Now the Serial Port can update clock and do some actions
- Ruby script to Serial communication

###### 1.2.1 (2012-10-04)
- Change IR remote controller codes
- Add libraries folder to git (IR lib included)
- Commented serial output to IR controller codes
- Some changes on buttons night lights

###### 1.2.0 (2011-07-27)
- Menu system to set lights state, date and time

###### 1.1.0 (2011-07-24)
- Release of the new system for push notifications on the screen
- Fixes bugs in the system control the intensity of the brightness of the LCD
- Clean lcd screen after 30 seconds with backlight off
- Turn off the main light after four hours on
- Show reminders when turn on any light

###### 1.0.4 (2011-07-22) beta
- New notification system on the screen

###### 1.0.3 (2011-06-05)
- System that monitors the time and current consumption of the lights

###### 1.0.2 (2011-05-12)
- New method to retrieve the time
- Problem with button locked solved
- Improvements in the symbol of temperature.

###### 1.0.1 (2011-05-08)
- Debug to verify problem with date and time
- Turn off the LED screen after 30 seconds with the lights out
- Adding support to the remote control of tv decoder
- Turn off the lights at two o'clock in the morning automatically

###### 1.0.0 (2011-05-07)
- Date and time on screen
- System temperature on the screen
- Displaying status of lights literally
- Analog button for commanding the lights
- Infrared sensor responding to commands from apple remote

LICENCE:
--------

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.