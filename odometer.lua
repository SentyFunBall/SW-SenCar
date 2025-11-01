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

local maxBattery = 256000 -- ENSURE SAME AS IN BATTERY SCRIPT

local ticks = 0
local eng = false
local odometer = 0
local speeds = {}
local fuelStart = 0
local avgSpeed = 0
local distance = 0
local fuelEcon = 0
local econSamples = {}

local isEv = property.getBool("EV Mode (Do not change)")

function onTick()
    local pulse = input.getBool(1) and not eng
    eng = input.getBool(1)
    local speed = input.getNumber(1)
    local fuel = input.getNumber(2)
    local Unit = input.getBool(32)

    if pulse then --get the starting fuel when the car turns on
        fuelStart = fuel -- or battery for ev
        distance = 0
        fuelEcon = 0
        avgSpeed = 0
        speeds = {}
        econSamples = {}
    end

    if eng and ticks % 30 == 0 and speed > 0.2 then
        local deltaDist = speed / 2 -- m per 0.5s
        odometer = odometer + deltaDist
        distance = distance + deltaDist
        speeds[#speeds + 1] = speed
        if #speeds > 240 then table.remove(speeds, 1) end -- 2min window
    end


    avgSpeed = 0
    for i = 1, #speeds do
        avgSpeed = (avgSpeed + speeds[i])
    end
    avgSpeed = #speeds > 0 and (avgSpeed / #speeds) or 0

    fuelUsed = (fuelStart - fuel) * (isEv and maxBattery or 1)
    if isEv then
        if distance > 1 then
            -- Swatts per km/mi
            local econ = (fuelUsed / distance) * (Unit and 1609.34 or 1000)
            -- Rolling average for smoothness
            econSamples[#econSamples + 1] = econ
            if #econSamples > 240 then table.remove(econSamples, 1) end
            local sum = 0
            for i = 1, #econSamples do sum = sum + econSamples[i] end
            fuelEcon = sum / #econSamples
            
        else
            fuelEcon = 0
        end
    else
        if Unit then --mpg
            fuelEcon =  (distance / 1609.34) / (fuelUsed / 3.785)--miles / gallon
        else --l/100km
            fuelEcon = distance/1000 / (fuelUsed*100) --idk blame nameous
        end
    end


    if fuelEcon ~= fuelEcon then fuelEcon = 0 end


    ticks = ticks + 1

    if Unit then --miles
        output.setNumber(1, odometer / 1609)
        output.setNumber(2, fuelEcon) -- swatts/mi
        output.setNumber(3, avgSpeed * 2.23)
        if isEv then
            output.setNumber(4, fuelUsed * 100 / maxBattery) --battery used in %
        else
            output.setNumber(4, fuelUsed/3.78)
        end
        output.setNumber(5, distance / 1609)
    else --km
        output.setNumber(1, odometer / 1000)
        output.setNumber(3, avgSpeed * 3.6)
        if isEv then
            output.setNumber(4, fuelUsed * 100 / maxBattery) --battery used in %
            output.setNumber(2, fuelEcon * 100) -- swatts/100km
        else
            output.setNumber(4, fuelUsed)
            output.setNumber(2, fuelEcon)
        end
        output.setNumber(5, distance / 1000)
    end
end
