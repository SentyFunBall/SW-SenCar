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

        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputBool(2, simulator:getIsToggled(2))
        simulator:setInputNumber(3, simulator:getSlider(1))
        simulator:setInputNumber(4, 0)
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
    {{74, 27, 99}, {124, 42, 161}, {182, 29, 224}}, --purple
    {{74, 27, 99}, {124, 42, 161}, {182, 29, 224}}, --temp
    {{74, 27, 99}, {124, 42, 161}, {182, 29, 224}}, -- temp
    {{74, 27, 99}, {124, 42, 161}, {182, 29, 224}}, --temp
    {{74, 27, 99}, {124, 42, 161}, {182, 29, 224}} --temp
}

app = 0
oldapp = 0
tick = 0
tick2 = 255
appNames = {"Home", "Weather", "Map", "Info", "Car", "Settings"}
function onTick()
    acc = input.getBool(1)
    exist = input.getBool(2)
    theme = input.getNumber(32)
if theme == 0 then
theme = property.getNumber("Theme")
end

    press = input.getBool(3)

    touchX = input.getNumber(1)
    touchY = input.getNumber(2)

    clock = input.getNumber(3)

    carName = property.getText("Car name")

    if input.getBool(32) then --
        clock = ("%02d"):format(math.floor(clock*24)%12)..("%02d"):format(math.floor((clock*1440)%60))
        if string.sub(clock, 1, 2) == "00" then
            clock = "12"..string.sub(clock, 3,-1)
        end
    else
        clock = ("%02d"):format(math.floor(clock*24))..("%02d"):format(math.floor((clock*1440)%60))
    end

    if isPointInRectangle(touchX, touchY, 10, 0, 12, 14) then
        app = 0
    end
    if isPointInRectangle(touchX, touchY, 36, 0, 13, 14) then
        app = 2 --map
    end
    if isPointInRectangle(touchX, touchY, 51, 0, 13, 14) then
        app = 3 --info
    end
    if isPointInRectangle(touchX, touchY, 22, 0, 13, 14) then
        app = 1 --weather
    end
    if isPointInRectangle(touchX, touchY, 66, 0, 13, 14) then
        app = 4 --car
    end
    if isPointInRectangle(touchX, touchY, 84,0,13,14) then
        app = 5 --settings
    end

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

    output.setNumber(3, app)
    output.setNumber(1, tick)
    oldapp = app
    output.setNumber(2, 16+app*6)
end

function onDraw()
    local _ = _colors[theme]
    if acc then
        if app == 0 then
            for x = 1, 32 do
                for y = 0, 21 do
                    c(
                        getBilinearValue(_[1][1], _[2][1], _[1][1], _[3][1], x/32, y/21),
                        getBilinearValue(_[1][2], _[2][2], _[1][2], _[3][2], x/32, y/21),
                        getBilinearValue(_[1][3], _[2][3], _[1][3], _[3][3], x/32, y/21)
                    )
                    screen.drawRectF(x*3-3, y*3, 3,3)
                end
            end
            drawLogo()
            c(200,200,200)
            screen.drawTextBox(0, 55, 96, 6, carName, 0, 0)
        end
        

        --draw dock
        c(_[1][1], _[1][2], _[1][3], 250)
        screen.drawRectF(0, 0, 96, 15)

        c(200, 200, 200)
        screen.drawTextBox(1, 1, 12, 30, clock, -1, -1)

        --apps
        -- weather app
        screen.setColor(33,117,255)
        screen.drawRectF(23,2,10,11)
        screen.drawLine(24,1,32,1)
        screen.drawLine(33,3,33,12)
        screen.drawLine(24,13,32,13)
        screen.drawLine(22,3,22,12)
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

        -- sencar 5
        screen.setColor(14,2,26)
        screen.drawRectF(52,2,11,11)
        screen.drawRectF(53,1,9,1)
        screen.drawRectF(63,3,1,9)
        screen.drawRectF(53,13,9,1)
        screen.drawRectF(51,3,1,9)
        screen.setColor(21,19,103)
        screen.drawRectF(56,3,3,2)
        screen.drawRectF(56,6,3,6)
        screen.setColor(1,0,2)
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


        -- info
        screen.setColor(_[2][1], _[2][2], _[2][3])
        screen.drawRectF(67,2,11,11)
        screen.drawRectF(68,1,9,1)
        screen.drawRectF(78,3,1,9)
        screen.drawRectF(68,13,9,1)
        screen.drawRectF(66,3,1,9)
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
        c(0,0,0,lerp(255, 1, clamp(tick, 0, 1)))
        screen.drawRectF(0,0,96,64)

    end
    if acc and tick2 >= 0 then
        if not exist then
            name = ""
        else
            name = appNames[app+1]
        end
        drawLogo(clamp(tick2, 0, 255), name)
    end
end

function c(...) local _={...}
    for i,v in pairs(_) do
     _[i]=_[i]^2.2/255^2.2*_[i]
    end
    screen.setColor(table.unpack(_))
end

function isPointInRectangle(x, y, rectX, rectY, rectW, rectH)
	return x > rectX and y > rectY and x < rectX+rectW and y < rectY+rectH
end

function lerp(v0,v1,t)
    return v1*t+v0*(1-clamp(t, 0, 1))
end

function clamp(x, min, max)
    return math.max(math.min(x, max), min)
end

function interpolate(x,y,alpha) --simple linear interpolation
	local difference=y-x
	local progress=alpha*difference
	local result=progress+x
	return result
end

function getBilinearValue(value00,value10,value01,value11,xProgress,yProgress)
	local top=interpolate(value00,value10,xProgress) --get progress across line A
	local bottom=interpolate(value01,value11,yProgress) --get line B progress
	local middle=interpolate(top,bottom,yProgress) --get progress of line going
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
    tick = tick or 255
    text = text or ""
    screen.setColor(15,2,30,tick)
    screen.drawRectF(27,11,41,41)
    screen.drawRectF(28,10,39,1)
    screen.drawRectF(26,12,1,39)
    screen.drawRectF(28,52,39,1)
    screen.drawRectF(68,12,1,39)
    c(0,162,232,tick)
    screen.drawLine(44,22,52,22)
    screen.drawLine(52,23,57,23)
    screen.drawLine(57,24,60,24)
    screen.drawLine(39,23,44,23)
    screen.drawLine(36,24,39,24)

    screen.drawLine(46,27,49,24)
    screen.drawLine(46,27,46,31)
    screen.drawLine(46,31,50,36)
    screen.drawLine(50,36,50,41)
    screen.drawLine(48,42,50,40)
    c(200,200,200,tick)
    screen.drawTextBox(0,44,96,8,text, 0, 0)
end