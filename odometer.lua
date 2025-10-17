-- Author: SentyFunBall
-- GitHub: https://github.com/SentyFunBall
-- Workshop:

--Code by STCorp. Do not reuse.--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "3x3")
    simulator:setProperty("Units", true)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputBool(2, not simulator:getIsToggled(1))
        simulator:setInputNumber(1, simulator:getSlider(1) * 100)
        simulator:setInputNumber(2, (-simulator:getSlider(2) * 50) + 50)
    end
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

ticks = 0
eng = false
odometer = 0
speeds = {0}
fuelStart = 0
fuelEnd = 0
avgSpeed = 0
fuelEcon = 0
distance = 0

function onTick()
    pulse = input.getBool(1) and not eng
    eng = input.getBool(1)
    pulse2 = input.getBool(2)
    speed = input.getNumber(1)
    fuel = input.getNumber(2)
    Unit = input.getBool(32)
    if pulse then --get the starting fuel when the engine turns on
        fuelStart = fuel
        distance = 0
        fuelEcon = 0
        avgSpeed = 0
        speeds = {0}
        fuelEnd = 0
    end

    if fuelStart ~= 0 and speed > 0.2 then
        fuelEnd = fuel
    end

    if eng and ticks % 30 == 0 and speed > 0.2 then --every half second, update the odometer driven by adding the current speed in m/t to the odometer
        odometer = odometer + speed / 2
        distance = distance + speed / 2
        speeds[#speeds + 1] = speed
    end

    --if fuelStart ~= 0 then --when the engine is ON, calculate the fuel used, average speed and fuel economy
    fuelUsed = math.abs(fuelStart - fuel)
    for i = 1, #speeds do
        avgSpeed = (avgSpeed + speeds[i]) or 0
    end

    if Unit then --mpg
        fuelEcon =  (distance / 1609.34) / (fuelUsed / 3.785)--miles / gallon
    else --l/100km
        fuelEcon = distance/1000 / (fuelUsed*100) --idk blame nameous
    end

    if fuelEcon ~= fuelEcon then fuelEcon = 0 end

    avgSpeed = (avgSpeed / #speeds) or 0
    --end

    ticks = ticks + 1

    if Unit then --miles
        output.setNumber(1, odometer / 1609)
        output.setNumber(2, fuelEcon)
        output.setNumber(3, avgSpeed * 2.23)
        output.setNumber(4, fuelUsed/3.78)
        output.setNumber(5, distance / 1609)
    else --km
        output.setNumber(1, odometer / 1000)
        output.setNumber(2, fuelEcon)
        output.setNumber(3, avgSpeed * 3.6)
        output.setNumber(4, fuelUsed)
        output.setNumber(5, distance / 1000)
    end
end
