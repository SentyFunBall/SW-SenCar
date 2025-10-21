--dashicons
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
    simulator:setScreen(1, "3x1")
    simulator:setProperty("Theme", 1)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputBool(2, simulator:getIsToggled(2))
        simulator:setInputBool(3, simulator:getIsToggled(3))
        simulator:setInputBool(9, true)
        simulator:setInputBool(10, simulator:getIsToggled(1))
        simulator:setInputBool(11, simulator:getIsToggled(2))
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

local theme = {}
local warning = false
local ticks = 0
local fuelCollected = false
local maxfuel = 180
local fuelwarn = property.getNumber("Fuel Warn %")/100
local tempwarn = property.getNumber("Temp Warn")
local isEv = property.getBool("EV Mode (Do not change)")

function onTick()
    leftBlinker = input.getBool(1)
    rightBlinker = input.getBool(2)
    fl = input.getBool(4)
    fr = input.getBool(5)
    rl = input.getBool(6)
    rr = input.getBool(7)
    otherWarning = input.getBool(8)
    exist = input.getBool(9)
    autodrive = input.getBool(10)
    esc = input.getBool(11)
    fuel = input.getNumber(1)
    temp = input.getNumber(2)
    lightmode = input.getNumber(3)
    cruisemode = input.getNumber(4)

    lock = not input.getBool(3)

    --input theme
    for i = 1, 9 do
        row = math.ceil(i/3)
        if not theme[row] then theme[row] = {} end
        theme[row][(i-1)%3+1] = input.getNumber(i+23)
    end
    if theme[1][1] == 0 then --fallback
        theme = {{47,51,78}, {86,67,143}, {128,95,164}}
    end

    if not fuelCollected then
        ticks = ticks + 1
    end
    if ticks == 20 then
        maxfuel = input.getNumber(1) or 180
        fuelCollected = true
        ticks = 0
    end

    if not isEv and (fuel/maxfuel < fuelwarn or temp > tempwarn) then
        warning = true
    elseif isEv and (fuel < 1) then 
        warning = true
    elseif otherWarning then
        warning = true
    else
        warning = false
    end
end

function onDraw()
    if exist then
        if leftBlinker then --oh my god, they're named the wrong way
            c(45,201,55)
            screen.drawTriangleF(62,24,62,30,71,27)
        end
        
        if rightBlinker then
            c(45,201,55)
            screen.drawTriangleF(34,24,34,30,25,27)
        end
        
        if cruisemode > 0 then
            if cruisemode == 1 then
                c(142, 230, 0)
            elseif cruisemode == 2 then
                c(27, 161, 250)
            end
            screen.drawRectF(36,26,1,5)
            screen.drawRectF(37,25,5,1)
            screen.drawRectF(42,26,1,5)
            screen.drawLine(35,23,37,25)
            screen.drawLine(37,26,40,29)
        end

        --- check engine light
        if warning then
            c(250, 166, 20)
            screen.drawRectF(47,23,3,1)
            screen.drawRectF(48,24,1,1)
            screen.drawRectF(44,26,1,3)
            screen.drawRectF(46,25,5,1)
            screen.drawRectF(51,26,1,3)
            screen.drawRectF(52,25,1,5)
            screen.drawRectF(45,27,1,1)
            screen.drawRectF(46,26,1,3)
            screen.drawRectF(47,28,1,1)
            screen.drawRectF(48,29,3,1)
        end
        
        --- ESC warning
        if not esc then
            c(200,50,50)
            screen.drawRectF(56,29,1,1)
            screen.drawRectF(55,28,1,1)
            screen.drawRectF(56,27,1,1)
            screen.drawRectF(59,29,1,1)
            screen.drawRectF(58,28,1,1)
            screen.drawRectF(59,27,1,1)
            screen.drawRect(56,24,3,2)
            screen.drawRectF(55,25,1,1)
            screen.drawRectF(60,25,1,1)
        end

        if lightmode == 1 then --low
            c(96,190,112)
            screen.drawRectF(31, 2, 3, 5)
            screen.drawLine(34, 3, 34, 6)

            screen.drawLine(29, 2, 26, 3)
            screen.drawLine(29, 4, 26, 5)
            screen.drawLine(29, 6, 26, 7)
        elseif lightmode == 2 then --bright
            c(27, 161, 250)
            screen.drawRectF(31, 2, 3, 5)
            screen.drawLine(34, 3, 34, 6)

            screen.drawLine(29, 2, 26, 2)
            screen.drawLine(29, 4, 26, 4)
            screen.drawLine(29, 6, 26, 6)
        end

        if autodrive then
            c(237, 202, 24)
            screen.drawRectF(63,2,3,1)
            screen.drawRectF(66,3,1,3)
            screen.drawRectF(63,6,3,1)
            screen.drawRectF(62,3,1,3)
            screen.drawRectF(63,4,3,1)
            screen.drawRectF(64,5,1,1)
            screen.drawRectF(61,1,1,1)
            screen.drawRectF(60,2,1,5)
            screen.drawRectF(61,7,1,1)
            screen.drawRectF(67,7,1,1)
            screen.drawRectF(68,2,1,5)
            screen.drawRectF(67,1,1,1)
        end
    end

    if fl or fr or rl or rr then
        c(theme[2][1], theme[2][2], theme[2][3], 250)
        screen.drawRectF(39,3,18,26)
        screen.drawLine(40,2,56,2)
        screen.drawLine(57,4,57,28)
        screen.drawLine(40,29,56,29)
        screen.drawLine(38,4,38,28)
        
        c(theme[1][1], theme[1][2], theme[1][3], 250)
        screen.drawRectF(44,5,8,4)
        screen.drawRectF(45,14,6,6)
        screen.drawLine(44,9,44,25)
        screen.drawLine(51,9,51,25)
        screen.drawLine(45,25,51,25)
        
        if fl then
            screen.drawLine(40,15,44,11)
        end
        
        if fr then
            screen.drawLine(55,15,51,11)
        end

        if rl then
            screen.drawLine(41,21,44,18)
        end

        if rr then
            screen.drawLine(54,21,51,18)
        end
    end

    if lock then
        c(200,50,50)
        screen.drawRectF(45,4,7,4)
        screen.drawRectF(46,2,1,2)
        screen.drawRectF(47,1,3,1)
        screen.drawRectF(50,2,1,3)
    end
end

function c(...) local _={...}
    for i,v in pairs(_) do
     _[i]=_[i]^2.2/255^2.2*_[i]
    end
    screen.setColor(table.unpack(_))
end