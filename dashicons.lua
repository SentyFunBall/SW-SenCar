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
        simulator:setInputBool(4, true)
        simulator:setInputBool(5, true)
        simulator:setInputBool(6, true)
        simulator:setInputBool(7, true)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("LifeBoatAPI")

_colors = {
    {{47,51,78}, {86,67,143}, {128,95,164}}, --sencar 5 in the micro
    {{17, 15, 107}, {22, 121, 196}, {48, 208, 217}}, --blue
    {{74, 27, 99}, {124, 42, 161}, {182, 29, 224}} --purple
}

warning = false
ticks = 0
fuelCollected = false
maxfuel = 180

function onTick()
    theme = property.getNumber("Theme")
    fuelwarn = property.getNumber("Fuel Warn %")/100
    batwarn = property.getNumber("Bat Warn %")/100
    tempwarn = property.getNumber("Temp Warn")

    leftBlinker = input.getBool(1)
    rightBlinker = input.getBool(2)
    cruise = input.getBool(3)
    fl = input.getBool(4)
    fr = input.getBool(5)
    rl = input.getBool(6)
    rr = input.getBool(7)
    otherWarning = input.getBool(8)
    fuel = input.getNumber(1)
    temp = input.getNumber(2)
    battery = input.getNumber(3)

    if not fuelCollected then
        ticks = ticks + 1
    end
    if ticks == 20 then
       maxfuel = input.getNumber(1) or 180
        fuelCollected = true
        ticks = 0
    end

    if battery < batwarn or fuel/maxfuel < fuelwarn or temp > tempwarn or otherWarning then 
        warning = true
    else 
        warning = false
    end
end

function onDraw()
    local _ = _colors[theme]
    
    if leftBlinker then
        c(45,201,55)
        screen.drawTriangleF(60,24,60,30,69,27)
    end

    if rightBlinker then
        c(45,201,55)
        screen.drawTriangleF(36,24,36,30,27,27)
    end

    if cruise then
        c(142, 230, 0)
        screen.drawLine(42,27,42,30)
        screen.drawLine(39,26,42,26)
        screen.drawLine(38,27,38,30)
        screen.drawRectF(38,25,1,1)
        screen.drawLine(39,27,41,29)
    end

    --- warning symbol
    if warning then
        c(200,50,50)
        screen.drawTriangle(44,29,52,29,48,22)
        screen.drawLine(48,25,48,27)
        screen.drawRectF(48,28,1,1)
    end

    --- battery warning
    if battery < batwarn then
        c(200,50,50)
        screen.drawRect(54,27,4,2)
        screen.drawRectF(55,26,1,1)
        screen.drawRectF(57,26,1,1)
    end

    if fl or fr or rl or rr then
        c(_[2][1], _[2][2], _[2][3], 250)
        screen.drawRectF(39,3,18,26)
        screen.drawLine(40,2,56,2)
        screen.drawLine(57,4,57,28)
        screen.drawLine(40,29,56,29)
        screen.drawLine(38,4,38,28)
        
        c(_[1][1], _[1][2], _[1][3], 250)
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
end

function c(...) local _={...}
    for i,v in pairs(_) do
     _[i]=_[i]^2.2/255^2.2*_[i]
    end
    screen.setColor(table.unpack(_))
end