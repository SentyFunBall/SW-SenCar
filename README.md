# SenCar 6
[Developer Documentation](docs/docs.md)

[Change logs](docs/logs.md)

## Personal. Powerful. Expandable.

SenCar 6 enhances your car with all new personalization features, seemless communication menthods, a brand new UI, drive modes, and more.

*SenCar 6's dashboard with all the icons enabled*

## Contents
1. [All new UI](#all-new-ui)
    1. [Themes](#themes)
    2. [Dashboard](#dashboard)
    3. [Widget Display](#widget-display)
    4. [Radio Display](#radio-display)
    5. [Central Display](#central-display)
2. [Everything New](#everything-new)
3. [List of SenCar 6 Vehicles](#list-of-cars)
4. [For Developers](#for-developers)
    1. [Included APIs](#included-apis)
    2. [Libs and APIs used](#libraries-and-apis-used)
    3. [Credits](#credits)

## All New UI
SenCar 6 features a brand new UI, made from scratch, with as little compromises as possible. There are 4 new screens, 2 are optional, for a full new experience of using SenCar 6, and any car it is in. SenCar 6 is designed to take over nearly every element of a car, and the 4 new screens let you control them perfectly. Built on top of the powerful SenOS architecture, it is easier than ever to control a car now. 

### Themes
SenCar 6 features 7 themes to customize your experience with the car to the max. Custom currated colors match each theme perfectly, so that they dont contrast eachother. 

### Dashboard
The dashboard has been redesigned from the ground up. 2 large speed and RPM dials occupy the screen with a map (with SenConnect 1.1 and later support). Fuel and temperture dials outline the edges of the large dials. Of course, the colors of the dashboard align with those in the current theme, giving a gorgeous look everywhere you are. 

### Widget Display
The widget display is a brand new addition to SenCar 6, and it allows you to view detailed information at a glance, such as the weather, a phone, trip stats, and more. Plus, SenCar 6 comes with an easy way to add your own Widgets via [WidgetAPI](docs/apis/widgetapi.md). The widget display is optional. The colors of each widget, and the gradient background, change with the theme.

SenCar 6 can change what widgets are displayed up and front, depending on what is most important. A huge storm might be a little more important than the fact that it's lunchtime. Up to 3 widgets can be displayed at once, giving you tons of information to be able to see at a glance.

### Radio Display
The radio display lets you see current information about the radio, such as whats playing, talk back with Push-To-Talk (PTT), or connect with third-party music options to play music.

### Central Display
The central display is where all the fun stuff happens. Climate, Weather, Settings, Maps, Control Center, and much more are all availble with the central display. The display works in an app-like fashion, with each app having a localized script for the most amount of features and performance. Settings lets you change everything about the car, from its theme, units, view its name and version, and much more. Control Center has all the stuff you want to access quickly, like the door lock, hazards, and privacy information. <sup>(SentyTek does not collect any information from SenCar 6, or any of the vehicles it is featured in.)</sup> Maps has all the latest SenConnect info, waypoints, and directions in the future. And so on. Car has all the car controls and things, weather has detailed weather reports. The central display has all the necessities to make a car functional.

## Everything New

### Drive Modes
4 drive modes customizes how the car behaves to allow for better control and performance during specific situations. Eco mode saves fuel and quiets down your car. Sport mode tightens the steering, and makes your car feel sportier. Tow mode turns on Advanced Traction Control, and prevents wheelslip while towing heavy loads. DAC mode keeps steering tight, lowers speed, and keeps torque high.

### Back up camera
After the removal of a backup camera in SenTOS Car 3, we have added it back, front and center on the dashboard. The back up camera also features guide markers, to tell you when you're getting close to a wall.

### SenConnect
SenConnect is our revolutionary way to easily communicate wirelessly in stormworks, in groups of up to 5 people. SenConnect lets you see where other people on your network are. With SenConnect, these locations are shown right up on the dashboard, with their name and car type shown too. You can disable sharing your location in the 

### Automatic this and that
New automatic lights, enhanced automatic transmission with a better shift warning, more realistic gear transition, and locking doors. SenCar 6 will automatically turn on and off the headlights and running lights if it's night, or if you're near a car. 

### Tow Mode
Tow mode, and the complimentary Towed mode, allows you to control something, or be controlled, though the SIBTaT standard. If your car has a baseplate, or a tow connector, then it'll show up on the main display. If you are towing a SentyTek vehicle, it'll show its status on the Widget Display, via WidgetAPI.

### So much more
- Horn
- Downshift protection
- Shows open doors on dashboard
- Enhanced trip stats
- Low fuel/battery alarms
- Enhanced clutch
- Developer support
- Open source
- More settings
- More "on-the-fly" settings

## List of Cars
Here is a list of every released car with SenCar 6
 - [Solstice 2022 RT](https://steamcommunity.com/sharedfiles/filedetails/?id=2905895118)

## For Developers
We have included a full documentation of the entire system [here](/docs/docs.md). Enjoy!
Below are the included APIs, the ones we used, and our inspiration

### Included APIs
[WidgetAPI](/docs/apis/widgetapi.md)


### Libraries and APIs used
 - [LifeBoatAPI](https://marketplace.visualstudio.com/items?itemName=NameousChangey.lifeboatapi)
 - [Lua 5.2 w/ Stormworks](https://www.lua.org/manual/5.2/)

### Inspiration
UI is heavily inspired off of next generation [Apple Carplay](https://www.wired.com/story/apple-carplay-dashboard-touchscreen-distracted-driving/).

UI is partially inspired off of Phil's car dashboard and map they posted one time in the Stormworks Discord server.

UI is partially inspired off of Android Auto.

### Credits
Programming and design - SentyFunBall

Programming and design - MerianBerry

UX Designer - SentyFunBall

Documentation writer - SentyFunBall

Marketing - SentyFunBall

Testing - So many people, of which I thank you all dearly.
