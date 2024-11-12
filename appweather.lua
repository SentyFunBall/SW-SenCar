--appmap
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

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(3, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.touchX)
        simulator:setInputNumber(2, screenConnection.touchY)

        simulator:setInputBool(1, true)
        simulator:setInputNumber(5, simulator:getSlider(1) - 0.5)
        simulator:setInputNumber(10, simulator:getSlider(2)-0.5)

        simulator:setInputNumber(3, 1)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

theme = {}
scrollPixels = 0
conditions = "Sunny"
showInfo = false

function onTick()
    acc = input.getBool(1)
    app = input.getNumber(3)
    units = input.getBool(32)

    touchX = input.getNumber(1)
    touchY = input.getNumber(2)
    press = input.getBool(3) and press + 1 or 0

    rain = input.getNumber(4)
    fog = input.getNumber(7)
    clock = input.getNumber(8)
    temp = input.getNumber(9)

    --input theme
    for i = 1, 9 do
        row = math.ceil(i/3)
        if not theme[row] then theme[row] = {} end
        theme[row][(i-1)%3+1] = input.getNumber(i+23)
    end
    if theme[1][1] == 0 then --fallback
        theme = {{47,51,78}, {86,67,143}, {128,95,164}}
    end

    if app == 1 then --weather
        maxScroll = open and 155 or 100 --adjust max scroll if dropdown is open
        scrollPixels = math.min(scrollPixels, maxScroll - 64)

        --scroll
        scrollUp = press > 0 and isPointInRectangle(0, 18, 12, 19)
        scrollDown = press > 0 and isPointInRectangle(0, 39, 12, 19)
        if scrollUp then
            scrollPixels = clamp(scrollPixels - 2, 0, 999)
        end
        if scrollDown then
            scrollPixels = scrollPixels + 2
        end

        if rain < 0.05 then 
            rain = "None" 
        elseif rain < 0.3 then 
            if temp < 5 then 
                rain = "Flurries"
            else
                rain = "Light"
            end
        elseif rain < 0.7 then 
            if temp < 5 then
                rain = "Heavy snow"
            else
                rain = "Moderate" 
            end
        else
            if temp < 5 then
                rain = "Snow storm"
            else
                rain = "Heavy" 
            end
        end

        --conditions
        if (rain == "Heavy" or rain == "Snow storm") and fog > 0.5 then
            if temp < 5 then
                conditions = "Blizzard"
                color = {207, 207, 207}
            else
                conditions = "Stormy"
                color = {86, 88, 89}
            end
        elseif rain ~= "None" then
            if temp < 5 then
                conditions = "Snowy"
                color = {204, 206, 207}
            else
                conditions = "Rainy"
                color = {141, 151, 158}
            end
        elseif fog > 0.3 then
            if fog > 0.7 then
                conditions = "Very foggy"
                color = {90, 110, 120}
                if temp < 5 then
                    conditions = "Freezing dense fog"
                    color = {106, 119, 125}
                end
            else
                conditions = "Foggy"
                color = {90, 110, 120}
                if temp < 5 then
                   conditions = "Freezing fog" 
                   color = {106, 119, 125}
                end
            end
        elseif temp < 5 then
            conditions = "Freezing"
            color = {165, 242, 243}
        else
            if clock > 0.3 and clock < 0.7 then --day
                conditions = "Sunny"
                color = {133, 197, 230}
            else --night
                conditions = "Clear"
                color = {2, 0, 28}
            end
        end

        if units then
            temp = string.format("%.0f*f", (temp) * (9/5) + 32)
        else
            temp = string.format("%.0f*c", temp)
        end
    end
end

function onDraw()
    if acc and app == 1 then
----------[[* MAIN OVERLAY *]]--
        c(table.unpack(color))
        screen.drawRectF(0, 0, 96, 64)

        hcolor = {200, 200, 200}
        rcolor = {150, 150, 150}
        tcolor = {50, 50, 50}

        c(table.unpack(hcolor))
        screen.drawText(15, 16-scrollPixels, "Current weather")
        c(100,100,100)
        screen.drawLine(15,23-scrollPixels,80,23-scrollPixels)
        drawInfo(15, 26-scrollPixels, "Conditions", conditions, hcolor, rcolor, tcolor)
        drawInfo(15 ,43-scrollPixels, "Temperature", temp, hcolor, rcolor, tcolor)
        drawInfo(15, 60-scrollPixels, "Rain", rain, hcolor, rcolor, tcolor)
        drawInfo(15, 77-scrollPixels, "fog", string.format("%.0f%%", fog*100), hcolor, rcolor, tcolor)

----------[[* CONTROLS OVERLAY *]]--
        c(theme[1][1], theme[1][2], theme[1][3], 250)
        screen.drawRectF(0, 15, 13, 64)

        if zoomin then c(150,150,150) else c(170, 170, 170)end
        drawRoundedRect(1, 19, 10, 18)
        if zoomout then c(150,150,150) else c(170, 170, 170)end
        drawRoundedRect(1, 40, 10, 18)
        c(100,100,100)
        screen.drawTriangleF(3, 29, 6, 25, 10, 29)
        screen.drawTriangleF(2, 48, 6, 53, 11, 48)
    end
end

function c(...) local _={...}
    for i,v in pairs(_) do
     _[i]=_[i]^2.2/255^2.2*_[i]
    end
    screen.setColor(table.unpack(_))
end

function clamp(v, l, u)
    return math.min(math.max(v, l), u)
end

function isPointInRectangle(rectX, rectY, rectW, rectH)
	return touchX > rectX and touchY > rectY and touchX < rectX+rectW and touchY < rectY+rectH
end

function drawInfo(x, y, header, text, hcolor, rcolor, tcolor) --function to draw some info with a header and a rounded rect
    c(table.unpack(hcolor))
    screen.drawText(x, y, header)
    c(table.unpack(rcolor))
    drawRoundedRect(x, y+6, #text*5+2, 8)
    c(table.unpack(tcolor))
    screen.drawText(x+2, y+8, text)
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

function drawFullToggle(x, y, state, text, bgcolor, tcolor)
    c(table.unpack(bgcolor))
    drawRoundedRect(x, y, #text*5+15, 8)
    drawToggle(x+#text*5+5, y+3, state)
    c(table.unpack(tcolor))
    screen.drawText(x+2, y+2, text)
end

function clamp(value, lower, upper)
    return math.min(math.max(value, lower), upper)
end
