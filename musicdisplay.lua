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

theme = {}
ticks = 0
tick = 0
godown = false
chup = false
chdown = false

function onTick()
    acc = input.getBool(1)
    exist = input.getBool(2)

    channel = math.ceil(input.getNumber(1))
    signalStrength = input.getNumber(2)
    isPlayingMusic = input.getBool(3)
    connected = input.getBool(5)

    --input theme
    for i = 1, 9 do
        row = math.ceil(i/3)
        if not theme[row] then theme[row] = {} end
        theme[row][(i-1)%3+1] = input.getNumber(i+23)
    end
    if theme[1][1] == 0 then --fallback
        theme = {{47,51,78}, {86,67,143}, {128,95,164}}
    end

    isPressed = input.getBool(4)
    -- channel buttons
    if isPressed and isPointInRectangle(input.getNumber(3), input.getNumber(4), 3, 19, 14, 10) then
       chup = true
    else
        chup = false
    end
    if isPressed and isPointInRectangle(input.getNumber(3), input.getNumber(4), 16 ,19, 14, 10) then
       chdown = true
    else
        chdown = false
    end

    output.setBool(1, chup)
    output.setBool(2, chdown)

    if exist and tick < 1 then
        tick = tick + 0.05
    end
    if not exist and tick > 0 then
        tick = tick - 0.05
    end
end

function onDraw()
    if acc then
        for i = 1, 33 do
            c(lerp(theme[2][1], theme[3][1], i/32), lerp(theme[2][2], theme[3][2], i/32), lerp(theme[2][3], theme[3][3], i/32))
            screen.drawLine(i-1, 0, i-1, 32)
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
                if ticks == 300 then
                    godown = true
                end
                if ticks == 0 then
                    godown = false
                end
                if not godown then
                    ticks = ticks + 1
                else
                    ticks = ticks - 1
                end
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
            if signalStrength > 0.9 then
                screen.drawRectF(4, 15, 4, 4)
                screen.drawRectF(11, 13, 4, 6)
                screen.drawRectF(18, 11, 4, 8)
                screen.drawRectF(25, 9, 4, 10)
            elseif signalStrength > 0.7 then
                screen.drawRectF(4, 15, 4, 4)
                screen.drawRectF(11, 13, 4, 6)
                screen.drawRectF(18, 11, 4, 8)
                screen.drawRect(25, 9, 3, 9)
            elseif signalStrength > 0.5 then
                screen.drawRectF(4, 15, 4, 4)
                screen.drawRectF(11, 13, 4, 6)
                screen.drawRect(18, 11, 3, 7)
                screen.drawRect(25, 9, 3, 9)
            elseif signalStrength > 0.3 then
                screen.drawRectF(4, 15, 4, 4)
                screen.drawRect(11, 13, 3, 5)
                screen.drawRect(18, 11, 3, 7)
                screen.drawRect(25, 9, 3, 9)
            elseif signalStrength > 0 then
                c(150, 50, 50)
                screen.drawRectF(4, 15, 4, 4)
                screen.drawRect(11, 13, 3, 5)
                screen.drawRect(18, 11, 3, 7)
                screen.drawRect(25, 9, 3, 9)
                c(theme[2][1], theme[2][2], theme[2][3])
            else
                screen.drawLine(4, 18, 8, 18)
                screen.drawLine(11, 18, 15, 18)
                screen.drawLine(18, 18, 22, 18)
                screen.drawLine(25, 18, 29, 18)
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
	return x > rectX and y > rectY and x < rectX+rectW and y < rectY+rectH
end