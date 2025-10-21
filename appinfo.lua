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
    simulator:setProperty("Car name", "Solstice")

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
        simulator:setInputNumber(4, 0)

        simulator:setInputNumber(3, 3)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

local SENCAR_VERSION = "6.dev"
local SENCAR_VERSION_BUILD = "1020252157b"
local APP_VERSIONS = {MAP = "1020252157b", INFO = "1020252157b", WEATHER = "1020252157b", CAR = "1020252157b", SETTINGS = "1020252157b"}

local theme = { { 47, 51, 78 }, { 86, 67, 143 }, { 128, 95, 164 } }

local scrollPixels = 0
local showInfo = false
local maxScroll = 0
local carName = property.getText("Car name")

local sleepTicks = 0
local isSleeping = false

function onTick()
    acc = input.getBool(1)
    app = input.getNumber(3)

    units = input.getBool(32)
    odometer = input.getNumber(4)
    econ = input.getNumber(5)
    avsp = input.getNumber(6)
    fuelUsed = input.getNumber(7)
    dist = input.getNumber(8)

    touchX = input.getNumber(1)
    touchY = input.getNumber(2)
    press = input.getBool(3) and press + 1 or 0

    local enableSleep = not input.getBool(5) -- NOT because settings output is inverted (WHY)

    if enableSleep then
        if press > 0 then
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

    if app == 3 and not isSleeping then --info
        maxScroll = showInfo and 260 or 140 --adjust max scroll if info button is on
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

        --show info button
        if press == 2 and isPointInRectangle(14, 128 - scrollPixels, 80, 10) then showInfo = not showInfo end
    end
    output.setBool(1, scrollDown)
end

function onDraw()
    if not acc or app ~= 3 or isSleeping then return end
----------[[* MAIN OVERLAY *]]--
    c(70, 70, 70)
    screen.drawRectF(0, 0, 96, 64)

    local hcolor = {theme[2][1]+25, theme[2][2]+25, theme[2][3]+25}
    local rcolor = theme[3]
    local tcolor = theme[1]

    drawInfo(15, 16-scrollPixels, "Car name", carName, hcolor, rcolor, tcolor)
    if units then
        drawInfo(15, 34-scrollPixels, "Distance Driven", ("%.1fmi"):format(odometer), hcolor, rcolor, tcolor)
        drawInfo(15, 52-scrollPixels, "Dist this trip", ("%.1fmi"):format(dist), hcolor, rcolor, tcolor)
        drawInfo(15, 70-scrollPixels, "Fuel Economy", ("%.1fmpg"):format(econ), hcolor, rcolor, tcolor)
        drawInfo(15, 88-scrollPixels, "Fuel used", ("%.1fgal"):format(fuelUsed), hcolor, rcolor, tcolor)
        drawInfo(15, 106-scrollPixels, "Average Speed", ("%.1fmph"):format(avsp), hcolor, rcolor, tcolor)
    else
        drawInfo(15, 34-scrollPixels, "Distance Driven", ("%.1fkm"):format(odometer), hcolor, rcolor, tcolor)
        drawInfo(15, 52-scrollPixels, "Dist this trip", ("%.1fkm"):format(dist), hcolor, rcolor, tcolor)
        drawInfo(15, 70-scrollPixels, "Fuel Economy", ("%.1fL/100km"):format(econ), hcolor, rcolor, tcolor)
        drawInfo(15, 88-scrollPixels, "Fuel used", ("%.1fL"):format(fuelUsed), hcolor, rcolor, tcolor)
        drawInfo(15, 106-scrollPixels, "Average Speed", ("%.1fkmh"):format(avsp), hcolor, rcolor, tcolor)
    end

    c(100, 100, 100)
    screen.drawLine(15, 124-scrollPixels, 80, 124-scrollPixels)
    drawFullToggle(15, 128-scrollPixels, showInfo, "Show OS info", rcolor, tcolor)
    if showInfo then
        drawInfo(15, 140-scrollPixels, "OS version", SENCAR_VERSION, hcolor, rcolor, tcolor)
        drawInfo(15, 157-scrollPixels, "os build number", SENCAR_VERSION_BUILD, hcolor, rcolor, tcolor)
        drawInfo(15, 174-scrollPixels, "map app build", APP_VERSIONS.MAP, hcolor, rcolor, tcolor)
        drawInfo(15, 191-scrollPixels, "info app build", APP_VERSIONS.INFO, hcolor, rcolor, tcolor)
        drawInfo(15, 208-scrollPixels, "wther app build", APP_VERSIONS.WEATHER, hcolor, rcolor, tcolor)
        drawInfo(15, 225-scrollPixels, "car app build", APP_VERSIONS.CAR, hcolor, rcolor, tcolor)
        drawInfo(15, 243-scrollPixels, "stting app build", APP_VERSIONS.SETTINGS, hcolor, rcolor, tcolor)
    end

----------[[* CONTROLS OVERLAY *]]--
    c(theme[1][1], theme[1][2], theme[1][3], 250)
    screen.drawRectF(0, 15, 13, 64)

    if scrollUp then c(150,150,150) else c(170, 170, 170)end
    drawRoundedRect(1, 19, 10, 18)
    if scrollDown then c(150,150,150) else c(170, 170, 170)end
    drawRoundedRect(1, 40, 10, 18)
    c(100,100,100)
    screen.drawTriangleF(3, 29, 6, 25, 10, 29)
    screen.drawTriangleF(2, 48, 6, 53, 11, 48)
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
