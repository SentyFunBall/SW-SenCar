# SenCar 6 Full Change Log

## Microcontroller
### New
- Added trailer reverse camera (SenCar 6 Max only)
- Added tow connector node
- Added anti-piracy measures to MC
- Added Adaptive Cruise Control as a Cruise Control mode if Jupyter Radar Driver is installed and connected to SenCar 6 Extras MC
- Added EV Mode toggle, which changes several settings
- (Lua too) Added new lock protections to prevent the car from moving when locked (If equipped)

### Changes
- Added Physics Sensor input to replace GPS, compass, speed inputs
- Condensed MC by combining instrument panel nodes, moving blinker logic to blinker MC, moving ECU node to ECU, and changing gearbox order
- Removed battery input
- Replaced SenConnect composite input with property toggle
- Changed how lights work - Now a cycle keybind is present to cycle through Off, Low Beams, and High Beams
- Cruise Control cycle keyind now present to cycle through Off, Cruise Control, and Adaptive Cruise Control (ACC only appears if Mercury Radar Driver is installed and connected to SenCar 6 Extras MC)
- Fixed issue with desynced touch inputs causing touch to appear at last location for a tick or two

## Lua
### New
- Added Theme RGB cycle mode in Settings app
- Added Theme Hue adjustment in Settings app
- Added Gradient Resolution slider in Settings app
- Added various new iconography on the dashboard
- Added new always on display to the dashboard, which displays the time
- If in EV mode, the car now uses a touchscreen based startup instead of button based.
- If in EV mode, the dashboard has new EV-specific iconography
- Added new "MP Mode", which turns off touch-enabled displays when not being actively pressed
- New "Locked" dashboard icon (If equipped)
- If the vehicle is locked (if equipped), the OS can be started but settings cannot be changes

### Changes
- Rebuilt theme engine from scratch to allow for much more customizable theme tuning
- Optimizations and refactored code across the entire operating system, up to 40% performance increase in default settings
- Replaced Low Battery indicator with ESC Off indicator
- Reduced font size of Drive Mode text
- Slightly adjusted gradients
- Fixed various issues related to touch inputs or misnamed variables