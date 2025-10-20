--centraldisplay
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
    simulator:setScreen(1, "3x2")
    simulator:setProperty("Theme", 1)
    simulator:setProperty("Units", true)
    simulator:setProperty("Car name", "Echolodia TE")
    simulator:setProperty("FONT1", "00019209B400AAAA793CA54A555690015244449415500BA0004903800009254956D4592EC54EC51C53A4F31C5354E52455545594104110490A201C7008A04504")
    simulator:setProperty("FONT2", "FFFE57DAD75C7246D6DCF34EF3487256B7DAE92E64D4975A924EBEDAF6DAF6DED74856B2D75A711CE924B6D4B6A4B6FAB55AB524E54ED24C911264965400000E")

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(2, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.touchX)
        simulator:setInputNumber(2, screenConnection.touchY)

        simulator:setInputBool(1, not simulator:getIsToggled(1))
        simulator:setInputBool(2, not simulator:getIsToggled(2))
        simulator:setInputBool(3, not simulator:getIsToggled(3))
        simulator:setInputNumber(3, simulator:getSlider(1)) --clock
        simulator:setInputNumber(4, 4) --gradient resolution
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

local theme = { { 47, 51, 78 }, { 86, 67, 143 }, { 128, 95, 164 } }

local app = 0
local oldapp = 0
local tick = 0
local tick2 = 255
local gradientResolution = 5
local gradientStep = 0
local appNames = {"Home", "Weather", "Map", "Info", "Car", "Settings", "SiBTaT+", "Camera"}
local ver = "v6.dev"
local lastClock = 0
local clockStr = ""

local xLim, yLim = 0, 0

function onTick()
    acc = input.getBool(1)
    exist = input.getBool(2)
    towConnected = input.getBool(4) -- note that MC has NOT from the connection

    press = input.getBool(3)
    touchX = input.getNumber(1)
    touchY = input.getNumber(2)

    clock = input.getNumber(3)
    gradientResolution = clamp(input.getNumber(4), 1, 9)

    carName = property.getText("Car name")
    
    -- load theme from inputs
    for i = 1, 9 do
        local row = math.ceil(i/3)
        local col = (i-1)%3+1
        local value = input.getNumber(i+23)
        if value ~= 0 then
            if not theme[row] then theme[row] = {} end
            theme[row][col] = value
        end
    end

    --clock
    if clock ~= lastClock then
        lastClock = clock
        if input.getBool(32) then
            clockStr = ("%02d"):format(math.floor(clock*24)%12)..("%02d"):format(math.floor((clock*1440)%60))
            if string.sub(clockStr, 1, 2) == "00" then
                clockStr = "12"..string.sub(clockStr, 3,-1)
            end
        else
            clockStr = ("%02d"):format(math.floor(clock*24))..("%02d"):format(math.floor((clock*1440)%60))
        end
    end

    --app switcher
    apps = {10, 22, 36, 51, 66, 84}
    for index, x in pairs(apps) do
        if isPointInRectangle(x, 0, 13, 14) then
            app = index-1
        end
    end

    --tow ones
    if towConnected and app == 0 and isPointInRectangle(85, 43, 8, 8) then
        app = 6 --tow
    end
    if towConnected and app == 0 and isPointInRectangle(85, 53, 8, 8) then
        app = 7 --camera
    end

    --delays
    if app ~= oldapp then
        tick = -1
        tick2 = 555
    end
    
    if exist and tick < 1 then
        tick = tick + 0.05
    end
    if exist and tick2 > 0 then
        tick2 = tick2 - 16
    end
    if not exist and tick > 0 then
        tick = tick - 0.05
        tick2 = tick2 + 12.75
    end

    -- gradient caching
    if gradientResolution ~= gradientStep then
        gradientStep = gradientResolution
        xLim = 96 / gradientResolution + 1
        yLim = 64/gradientResolution+1
    end

    output.setNumber(3, app)
    oldapp = app
end

function onDraw()
    if not acc then return end

    -- draw background gradient
    -- this is the most expensive fucking thing in the entire OS
    if app == 0 then
        for x = 1, xLim do
            for y = 0, yLim do
                local xRatio, yRatio = x/xLim, y/yLim
                c(
                    getBilinearValue(theme[1][1], theme[2][1], theme[1][1], theme[3][1], xRatio, yRatio),
                    getBilinearValue(theme[1][2], theme[2][2], theme[1][2], theme[3][2], xRatio, yRatio),
                    getBilinearValue(theme[1][3], theme[2][3], theme[1][3], theme[3][3], xRatio, yRatio)
                )

                screen.drawRectF(x*gradientStep-gradientStep, y*gradientStep, gradientStep,gradientStep)
            end
        end

        drawLogo(255,"") --draw logo with full opacity and no text
        c(200,200,200)
        screen.drawTextBox(0, 55, 96, 6, carName, 0, 0)

        if towConnected then
            --tow apps tray
            c(theme[1][1], theme[1][2], theme[1][3], 250)
            drawRoundedRect(84,42,10,20)

            --trailer settings button
            screen.setColor(100,100,100)
            drawRoundedRect(85,43,8,8)
            screen.setColor(50,50,50)
            screen.drawRectF(90,48,4,1)
            screen.drawRectF(90,49,1,1)
            screen.drawRectF(92,49,1,1)
            c(100,200,100)
            screen.drawRectF(87,44,4,3)
            screen.drawRectF(86,45,1,1)
            screen.setColor(0,0,0)
            screen.drawRectF(85,49,2,1)
            screen.drawRectF(86,50,1,1)
            screen.drawRectF(87,50,2,1)
            screen.setColor(200,200,200)
            screen.drawRectF(88,49,1,1)
            screen.drawRectF(90,45,3,1)
            screen.drawRectF(91,44,1,1)
            screen.drawRectF(91,46,1,1)

            --trailer camera button
            screen.setColor(33,117,255)
            drawRoundedRect(85,53,8,8)
            screen.setColor(0,0,0)
            screen.drawRectF(86,55,7,5)
            screen.drawRectF(87,54,2,1)
            screen.setColor(200,200,200)
            screen.drawRectF(89,57,1,1)
            screen.drawRectF(89,54,1,1)
        end
    end
    

    --draw dock
    c(theme[1][1], theme[1][2], theme[1][3], 250)
    screen.drawRectF(0, 0, 96, 15)

    c(200, 200, 200)
    screen.drawTextBox(1, 1, 12, 30, clockStr, -1, -1)

    --apps
    -- weather app
    screen.setColor(33,117,255)
    drawRoundedRect(22,1,11,12)
    screen.setColor(226,168,16)
    screen.drawRectF(24,2,2,4)
    screen.drawRectF(23,3,4,2)
    screen.setColor(255,255,255)
    screen.drawRectF(26,7,6,3)
    screen.drawRectF(27,6,5,1)
    screen.drawRectF(28,5,3,1)
    screen.drawRectF(32,7,1,3)
    screen.drawRectF(25,8,1,2)

    -- maps
    screen.setColor(255,255,255)
    screen.drawRectF(43,1,1,4)
    screen.drawRectF(44,5,5,1)
    screen.drawRectF(44,11,5,1)
    screen.drawRectF(43,12,1,2)
    screen.setColor(195,181,150)
    screen.drawRectF(36,6,7,6)
    screen.drawRectF(38,12,5,2)
    screen.drawRectF(37,12,1,1)
    screen.drawRectF(44,12,4,1)
    screen.drawRectF(44,13,3,1)
    screen.drawRectF(44,6,5,5)
    screen.setColor(40,139,20)
    screen.drawRectF(37,2,6,3)
    screen.drawRectF(44,2,4,3)
    screen.drawRectF(48,3,1,2)
    screen.drawRectF(44,1,3,1)
    screen.drawRectF(38,1,5,1)
    screen.drawRectF(36,3,1,2)
    screen.setColor(3,124,239)
    screen.drawRectF(36,5,8,1)
    screen.drawRectF(43,6,1,5)
    screen.setColor(3,55,239)
    screen.drawRectF(43,11,1,1)
    screen.setColor(250,183,15)
    screen.drawLine(36,7,42,12)
    screen.drawLine(44,13,45,13)

    -- info
    screen.setColor(14,2,26)
    drawRoundedRect(51,1,12,12)
    screen.setColor(21,19,103)
    screen.drawRectF(56,3,3,2)
    screen.drawRectF(56,6,3,6)
    screen.setColor(0,0,0)
    screen.drawRectF(54,3,2,1)
    screen.drawRectF(52,4,2,1)
    screen.drawRectF(51,5,1,1)
    screen.drawRectF(56,12,2,1)
    screen.drawRectF(54,13,2,1)
    screen.drawRectF(54,6,2,1)
    screen.drawRectF(52,7,2,1)
    screen.drawRectF(54,4,2,1)
    screen.drawRectF(51,8,1,1)
    screen.drawRectF(52,5,2,1)
    screen.drawRectF(51,6,1,1)
    screen.drawRectF(54,7,2,6)
    screen.drawRectF(52,8,2,5)
    screen.drawRectF(53,13,1,1)
    screen.drawRectF(51,9,1,3)

    -- car options
    screen.setColor(theme[2][1], theme[2][2], theme[2][3])
    drawRoundedRect(66,1,12,12)
    screen.setColor(0,0,0)
    screen.drawRectF(70,2,5,3)
    screen.drawRectF(70,5,1,7)
    screen.drawRectF(74,5,1,7)
    screen.drawRectF(71,7,3,2)
    screen.drawRectF(71,10,3,2)
    screen.drawRectF(69,5,1,1)
    screen.drawRectF(68,6,1,1)
    screen.drawRectF(75,5,1,1)
    screen.drawRectF(76,6,1,1)
    screen.drawRectF(75,8,1,1)
    screen.drawRectF(76,9,1,1)
    screen.drawRectF(69,8,1,1)
    screen.drawRectF(68,9,1,1)

    --control center button
    c(100, 100, 100)
    screen.drawLine(81, 2, 81, 13)
    c(150, 150, 150)
    drawRoundedRect(84, 1, 10, 12)
    c(200,200,200)
    drawToggle(85, 3, false)
    drawToggle(85, 8, true)

    --home button
    drawRoundedRect(11, 1, 8, 12)
    c(100, 100, 100)
    screen.drawTriangleF(12,7.5,18,7.5,15,4.5)
    screen.drawRectF(13,8.5,5,4)
    c(200,200,200)
    screen.drawRectF(15,10.5,1,2)

    --current app dot thing
    if app ~= 0 then
        c(250,250,250)
        if app == 5 then
            screen.drawLine(88, 14, 91, 14)
        else
            screen.drawLine(10+app*15, 14, 15+app*15, 14)
        end
    end

    --cover
    c(0,0,0,lerp(255, 0, clamp(tick, 0, 1)))
    screen.drawRectF(0,0,96,64)

    if tick2 >= 0 then
        name = not exist and "" or appNames[app+1]
        drawLogo(clamp(tick2, 0, 255), name)
        c(100,100,100,220)
        screen.drawText(1, 58, ver)
    end
end

function c(...) local _={...}
    for i,v in pairs(_) do
        _[i]=_[i]^2.2/255^2.2*_[i]
    end
    screen.setColor(table.unpack(_))
end

function isPointInRectangle(rectX, rectY, rectW, rectH)
	return touchX > rectX and touchY > rectY and touchX < rectX+rectW and touchY < rectY+rectH
end

function clamp(x, min, max)
    return math.max(math.min(x, max), min)
end

function lerp(v0,v1,t)
    return v0+t*(v1-v0)
  end

function getBilinearValue(value00,value10,value01,value11,xProgress,yProgress)
	top=lerp(value00,value10,xProgress) --get progress across line A
	bottom=lerp(value01,value11,yProgress) --get line B progress
	middle=lerp(top,bottom,yProgress) --get progress of line going
	return middle                              --between point A and point B
end

function drawRoundedRect(x, y, w, h)
    screen.drawRectF(x+1, y+1, w-1, h-1) --body
    screen.drawLine(x+2, y, x+w-1, y) --top
    screen.drawLine(x, y+2, x, y+h-1) --left
    screen.drawLine(x+w, y+2, x+w, y+h-1) --right
    screen.drawLine(x+2, y+h, x+w-1, y+h) --bottom
end

function drawToggle(x,y,state)
    if state then
        c(100,200,100)
        screen.drawLine(x+1, y, x+7, y)
        screen.drawLine(x, y+1, x+6, y+1)
        screen.drawLine(x+1, y+2, x+7, y+2)
        c(200,200,200)
        screen.drawLine(x+7, y, x+7, y+3)
        screen.drawLine(x+6, y+1, x+9, y+1)
    else
        c(100,100,100)
        screen.drawLine(x+2, y, x+8, y)
        screen.drawLine(x+3, y+1, x+9, y+1)
        screen.drawLine(x+2, y+2, x+8, y+2)
        c(200,200,200)
        screen.drawLine(x+1, y, x+1, y+3)
        screen.drawLine(x, y+1, x+3, y+1)
    end
end

function drawLogo(tick, text)
    --[[c(theme[3][1],theme[3][2],theme[3][3],tick)
    drawRoundedRect(26,18,42,34)]]
    c(200,200,200,tick)
    screen.drawTextBox(0,44,96,8,text, 0, 0)
    
    c(30, 100, 196, tick)
    screen.drawRectF(56,27,2,13)
    screen.drawRectF(55,28,1,11)
    screen.drawRectF(58,28,1,11)
    screen.drawRectF(36,21,27,2)
    screen.drawRectF(35,23,27,1)
    screen.drawRectF(38,20,24,1)
    screen.drawRectF(35,22,5,8)
    screen.drawRectF(34,24,1,4)
    screen.drawRectF(40,24,1,1)
    screen.drawRectF(40,30,5,8)
    screen.drawRectF(35,36,7,4)
    screen.drawRectF(39,35,5,4)
    screen.drawRectF(34,37,1,2)
    screen.drawRectF(45,32,1,4)
    screen.drawRectF(38,28,4,4)
    screen.drawRectF(36,29,8,2)
end