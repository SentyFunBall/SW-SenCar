-- Author: SentyFunBall
-- GitHub: https://github.com/SentyFunBall
-- Workshop: 

--Code by STCorp. Do not reuse.--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

-- Heavily abusing LifeBoatAPI's ability to paste code from other files
-- This literally gets pasted into dash.lua.

if (not usingSenconnect) and info.gear ~= 1 then
    --dont draw map or zoom btns if we're in reverse or if SC is connected (haha magic boolean)
    --screenX, screenY = map.screenToMap(info.gpsX, info.gpsY, 2, 96, 32, 58, 25)
    screen.drawMap(info.gpsX, info.gpsY, mapZoom)
    --map icon
    c(theme[3][1], theme[3][2], theme[3][3])
    drawPointer(48,16,info.compass, 5)

    --map zoom buttons
    c(50, 50, 50)
    screen.drawRectF(24, 28, 3, 1) --minus
    screen.drawRectF(69, 27, 1, 3) --plus
    screen.drawRectF(68, 28, 3, 1)
end

--side gradients
c(theme[1][1], theme[1][2], theme[1][3], 250)
screen.drawRectF(0, 0, 4, 32)
screen.drawRectF(92, 0, 4, 32)
for i=0, 42 do
    c(theme[1][1], theme[1][2], theme[1][3], easeLerp(250, 50, i/42))
    screen.drawLine(i+4, 0, i+4, 32)
    screen.drawLine(96-i-5, 0, 96-i-5, 32)
end

-- circles
c(theme[1][1], theme[1][2], theme[1][3],250) --i love tables
drawCircle(16, 16, 12, 0, 21, 0, pi2)
drawCircle(80, 16, 12, 0, 21, 0, pi2)

-- empty dials
local dialStart = -130/2*oneDeg --bunch of like cool math stuff
local dialEnd = 230*oneDeg
local outStart = 130/5*oneDeg
local outEnd = 120*oneDeg

c(theme[1][1]-15, theme[1][2]-15, theme[1][3]-15)
drawCircle(16, 16, 10, 8, 60, dialStart, dialEnd) --speed
drawCircle(80, 16, 10, 8, 60, dialStart, dialEnd) --rps
drawCircle(16, 16, 15, 13, 60, outStart, outEnd) --fuel
drawCircle(80, 16, 15, 13, 60, outStart, outEnd, -1) --temp

-- labels (credit to mrlennyn for the ui builder (fuck off copilot i thought i uninstalled you))
if info.properties.ev then
    --- power usage
    c(150, 150, 150)
    screen.drawRectF(93,27,2,2)
    screen.drawLine(93,29,91,31)
    screen.drawRectF(91,27,2,1)
    screen.drawRectF(92,26,2,1)
    screen.drawRectF(93,25,2,1)
else
--- temp
    if info.temp > info.properties.tempwarn then
        c(150,50,50)
    else
        c(150,150,150)
    end
    screen.drawLine(90,30,95,30)
    screen.drawLine(90,28,95,28)
    screen.drawLine(92,24,92,28)
    screen.drawRectF(93,24,1,1)
    screen.drawRectF(93,26,1,1)
end

if info.properties.ev then
    -- battery
    c(150, 150, 150)
    screen.drawRect(1, 27, 5, 3)
    screen.drawRectF(7, 28, 1, 2)
else
    --- fuel
    if info.fuel / info.properties.maxfuel < info.properties.fuelwarn then
        c(150, 50, 50)
    else
        c(150, 150, 150)
    end
    screen.drawRectF(1,29,3,2)
    screen.drawRect(1,26,2,2)
    screen.drawLine(5,27,5,31)
    screen.drawRectF(4,29,1,1)
    screen.drawRectF(4,26,1,1)
end

--- drive modes
c(theme[2][1], theme[2][2], theme[2][3])
if info.drivemode == 1 then --eco
    dst(43,2,"Eco")
elseif info.drivemode == 2 then --sport
    dst(39,2,"Sport")
elseif info.drivemode == 3 then --tow
    dst(43,2,"Tow")
elseif info.drivemode == 4 then --dac
    dst(43,2,"DAC")
end

-- dial that fills up
c(theme[2][1], theme[2][2], theme[2][3])
drawCircle(16, 16, 10, 8, 60, dialStart, math.min(info.speed / 100 / info.properties.topspeed, 1) * 230 * oneDeg) --speed
if info.rps > info.properties.upshift then c(180, 53, 35) else c(theme[2][1], theme[2][2], theme[2][3]) end
if info.properties.ev then
    drawCircle(80, 16, 10, 8, 60, dialStart, math.min(info.rps * 230 * oneDeg)) -- motor throttle
else
    drawCircle(80, 16, 10, 8, 60, dialStart, math.min(info.rps / (info.properties.upshift + 5), 1) * 230 * oneDeg) --rps
end

c(theme[3][1], theme[3][2], theme[3][3])

if info.properties.ev then
    drawCircle(16, 16, 15, 13, 60, outStart, info.fuel * 120 * oneDeg) -- battery
    drawCircle(80, 16, 15, 13, 60, outStart, math.min(info.temp / 16, 1) * 120 * oneDeg, -1) -- gen power production. 20 swatts/sec is probably max
else
    drawCircle(16, 16, 15, 13, 60, outStart, math.min(info.fuel / info.properties.maxfuel, 1) * 120 * oneDeg) --fuel, should clamp within fuel we got in 20th tick as max fuel
    drawCircle(80, 16, 15, 13, 60, outStart, math.min(info.temp / 110, 1) * 120 * oneDeg, -1) --temp, clamps within -inf and 120
end

--text
-- speed
c(200,200,200)

local function drawSpeed(speed, unit, offset)
    speed = string.format("%.0f", speed)
    screen.drawText(offset, 12, speed)
    c(150,150,150)
    dst(11, 20, unit)
end

if info.properties.unit then
    mph = math.floor(info.speed * 2.23)
    offset = mph < 10 and 14 or mph < 100 and 12 or 9
    drawSpeed(mph, "mph", offset)
else
    kph = math.floor(info.speed * 3.6)
    offset = kph < 10 and 14 or kph < 100 and 12 or 9
    drawSpeed(kph, "kph", offset)
end

-- gear
c(200,200,200)
if info.gear == 0 then
    dst(78,9,"P",2)
elseif info.gear == 1 then
    dst(78,9,"R",2)
elseif info.gear == 2 then
    dst(78,9,"N",2)
elseif info.gear >= 3 then
    if info.properties.ev or info.properties.trans then
        dst(info.properties.ev and 78 or 77, 9,"D",2)
        if not info.properties.ev and info.properties.trans then
            dst(84,13,string.format("%.0f", info.gear-2))
        end
    else
        dst(78,9,string.format("%.0f", info.gear-2),2)
    end
end

-- units
c(150, 150, 150)
if info.properties.ev then
    dst(75, 20, "PWR")
else
    dst(info.properties.trans and 73 or 74, 20, info.properties.trans and "auto" or "man")
end

if useDimDisplay then
    screen.setColor(0, 0, 0, 150)
    screen.drawRectF(0, 0, 100, 32)
end
