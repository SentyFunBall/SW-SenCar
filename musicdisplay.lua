--musicdisplay
-- Author: SentyFunBall
-- GitHub: https://github.com/SentyFunBall
-- Workshop: <WorkshopLink>

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
    simulator:setScreen(1, "1x1")
    simulator:setProperty("Theme", 1) --we dont have the "Use Drive Modes" property because that is handled by the transmission


    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputNumber(1, 1)
        simulator:setInputNumber(2, simulator:getSlider(1))
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(1, true)
        simulator:setInputBool(2, simulator:getIsToggled(2))
        simulator:setInputBool(3, screenConnection.isTouched)
    end;
end
---@endsection

--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

local theme = { { 47, 51, 78 }, { 86, 67, 143 }, { 128, 95, 164 } }
local ticks = 0
local tick = 0
local goDown = false
local chUp = false
local chDown = false
local sleepTicks = 0
local isSleeping = false

function onTick()
    acc = input.getBool(1)
    local exist = input.getBool(2)

    channel = math.ceil(input.getNumber(1))
    signalStrength = input.getNumber(2)
    local isPlayingMusic = input.getBool(3)
    local isPressed = input.getBool(4)
    connected = input.getBool(5)

    local enableSleep = not input.getBool(31) -- NOT because settings output is inverted (WHY)

    -- load from inputs
    for i = 1, 9 do
        local row = math.ceil(i/3)
        local col = (i-1)%3+1
        local value = input.getNumber(i+23)
        if value ~= 0 then
            if not theme[row] then theme[row] = {} end
            theme[row][col] = value
        end
    end

    -- sleep logic
    if enableSleep then
        if isPressed then
            sleepTicks = 0
            isSleeping = false
        else
            sleepTicks = sleepTicks + 1
            if sleepTicks > 600 then
                isSleeping = true
            end
        end
    else
        sleepTicks = 0
        isSleeping = false
    end

    if not isSleeping then
    -- channel buttons
        chUp = isPressed and isPointInRectangle(input.getNumber(3), input.getNumber(4), 3, 19, 14, 10)
        chDown = isPressed and isPointInRectangle(input.getNumber(3), input.getNumber(4), 16 ,19, 14, 10)
    end

    output.setBool(1, chUp)
    output.setBool(2, chDown)

    if exist and tick < 1 then
        tick = tick + 0.05
    end
    if not exist and tick > 0 then
        tick = tick - 0.05
    end

    if isPlayingMusic then
        if ticks == 300 then
            goDown = true
        end
        if ticks == 0 then
            goDown = false
        end
        if not goDown then
            ticks = ticks + 1
        else
            ticks = ticks - 1
        end
    end
end

function onDraw()
    if not acc or isSleeping then return end

    for i = 1, 11 do
        c(lerp(theme[2][1], theme[3][1], i / 11), lerp(theme[2][2], theme[3][2], i / 11),
            lerp(theme[2][3], theme[3][3], i / 11))
        screen.drawRectF((i * 3) - 3, 0, 3, 32)
    end

    if connected then
        --background
        if not isPlayingMusic then
            c(theme[1][1], theme[1][2], theme[1][3],250) --i love tables
            screen.drawRectF(3,3,26,26)
            screen.drawLine(4,2,28,2)
            screen.drawLine(29,4,29,28)
            screen.drawLine(4,29,28,29)
            screen.drawLine(2,4,2,28)
            ticks = 0
        else
            c(theme[1][1], theme[1][2], lerp(theme[1][3], theme[1][3]+25, ticks/300), 250)
            screen.drawRectF(3,3,26,26)
            screen.drawLine(4,2,28,2)
            screen.drawLine(29,4,29,28)
            screen.drawLine(4,29,28,29)
            screen.drawLine(2,4,2,28)
        end

        --- stupid button outlines
        c(theme[1][1]+55, theme[1][2]+55, theme[1][3]+55, 250)
        screen.drawLine(3,20,29,20)
        screen.drawRectF(15,21,2,8)

        screen.drawLine(16,28,26,28)
        screen.drawLine(26,27,27,27)
        screen.drawLine(27,26,28,26)
        screen.drawLine(28,21,28,26)

        screen.drawLine(6,28,15,28)
        screen.drawLine(5,27,6,27)
        screen.drawLine(4,26,5,26)
        screen.drawLine(3,21,3,26)
        
        --- text
        c(theme[2][1], theme[2][2], theme[2][3])
        screen.drawText(4,4, "Ch:" .. channel)

        --- signal strength bars
        local bars = {
            {4, 15, 4, 4},
            {11, 13, 4, 6},
            {18, 11, 4, 8},
            {25, 9, 4, 10}
        }
        
        if signalStrength <= 0 then
            for i = 1, 4 do
                local x = bars[i][1]
                screen.drawLine(x, 18, x + 4, 18)
            end
        else
            local filledBars = math.ceil(signalStrength * 4)
            local isWeak = signalStrength <= 0.3
            
            if isWeak then
                c(150, 50, 50)
            end
            
            for i = 1, 4 do
                local x, y, w, h = table.unpack(bars[i])
                if i <= filledBars then
                    screen.drawRectF(x, y, w, h)
                else
                    screen.drawRect(x, y, w - 1, h - 1)
                end
            end
            
            if isWeak then
                c(theme[2][1], theme[2][2], theme[2][3])
            end
        end

        --- up arrow
        if chup then
            c(theme[3][1], theme[3][2], theme[3][3])
            screen.drawLine(9,22,9,27)
            screen.drawLine(10,23,10,25)
            screen.drawLine(8,23,8,25)
            screen.drawRectF(11,24,1,1)
            screen.drawRectF(7,24,1,1)
        else
            c(theme[2][1], theme[2][2], theme[2][3])
            screen.drawLine(9,22,9,27)
            screen.drawLine(10,23,10,25)
            screen.drawLine(8,23,8,25)
            screen.drawRectF(11,24,1,1)
            screen.drawRectF(7,24,1,1)
        end

        --- down arrow
        if chdown then
            c(theme[3][1], theme[3][2], theme[3][3])
            screen.drawLine(22,22,22,27)
            screen.drawLine(23,24,23,26)
            screen.drawLine(21,24,21,26)
            screen.drawRectF(24,24,1,1)
            screen.drawRectF(20,24,1,1)
        else
            c(theme[2][1], theme[2][2], theme[2][3])
            screen.drawLine(22,22,22,27)
            screen.drawLine(23,24,23,26)
            screen.drawLine(21,24,21,26)
            screen.drawRectF(24,24,1,1)
            screen.drawRectF(20,24,1,1)
        end
    else
        c(theme[1][1], theme[1][2], theme[1][3],250) --i love tables
        screen.drawRectF(3,3,26,26)
        screen.drawLine(4,2,28,2)
        screen.drawLine(29,4,29,28)
        screen.drawLine(4,29,28,29)
        screen.drawLine(2,4,2,28)
        screen.setColor(100, 100, 100)
        screen.drawTextBox(4, 4, 28, 28, "comp not connected")
    end

    c(0,0,0,lerp(255, 1, tick))
    screen.drawRectF(0,0,32,32)
end

function c(...) local _={...}
    for i,v in pairs(_) do
     _[i]=_[i]^2.2/255^2.2*_[i]
    end
    screen.setColor(table.unpack(_))
end

function lerp(v0,v1,t)
    return v1*t+v0*(1-t)
end

function isPointInRectangle(x, y, rectX, rectY, rectW, rectH)
    return x > rectX and y > rectY and x < rectX + rectW and y < rectY + rectH
end
