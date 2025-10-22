--dash
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
    simulator:setProperty("FONT1", "00019209B400AAAA793CA54A555690015244449415500BA0004903800009254956D4592EC54EC51C53A4F31C5354E52455545594104110490A201C7008A04504")
    simulator:setProperty("FONT2", "FFFE57DAD75C7246D6DCF34EF3487256B7DAE92E64D4975A924EBEDAF6DAF6DED74856B2D75A711CE924B6D4B6A4B6FAB55AB524E54ED24C911264965400000E")
    simulator:setProperty("Fuel Warn %", 20)
    simulator:setProperty("Bat Warn %", 50)
    simulator:setProperty("Temp Warn", 70)
    simulator:setProperty("Upshift RPS", 17) --read up more on what causes automatics to shift
    simulator:setProperty("Downshift RPS", 11)
    simulator:setProperty("Transmission Default", true) --true for automatic
    simulator:setProperty("Units", true) --true for imperial
    simulator:setProperty("Theme", 3) --we dont have the "Use Drive Modes" property because that is handled by the transmission
    simulator:setProperty("Car name", "SenCar 5 DEV")
    simulator:setProperty("Top Speed (m/s)", 66)
    simulator:setProperty("EV Mode (Do not change)", true)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        --[[ touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)]]

        -- NEW! button/slider options from the UI
        simulator:setInputBool(1, false)
        simulator:setInputBool(2, false)
        simulator:setInputBool(32, false)

        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputNumber(1, simulator:getSlider(1)*100)
        simulator:setInputNumber(2, math.floor(simulator:getSlider(2) * 7))
        simulator:setInputNumber(3, simulator:getSlider(3)*25)
        simulator:setInputNumber(4, simulator:getSlider(4)*181)
        simulator:setInputNumber(5, simulator:getSlider(5)*200)
        simulator:setInputNumber(8, simulator:getSlider(8))
        simulator:setInputNumber(9, simulator:getSlider(9))
        simulator:setInputNumber(10, screenConnection.touchX)
        simulator:setInputNumber(11, screenConnection.touchY)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

local theme = { { 47, 51, 78 }, { 86, 67, 143 }, { 128, 95, 164 } }
local info = {properties = {}}
local fuelCollected = false
local ticks = 0
local mapZoom = 2

local pi = math.pi
local pi2 = pi*2
local oneDeg = pi/180

local lastClock = 0
local clockstr = ""

info.properties.fuelwarn = property.getNumber("Fuel Warn %")/100
info.properties.tempwarn = property.getNumber("Temp Warn")
info.properties.upshift = property.getNumber("Upshift RPS")
info.properties.downshift = property.getNumber("Downshift RPS")
info.properties.topspeed = property.getNumber("Top Speed (m/s)")/100
info.properties.ev = property.getBool("EV Mode (Do not change)")
local usingSenconnect = property.getBool("Enable SenConnect") --disables map rendering, in favor of SenConnect's map

function onTick()
    acc = input.getBool(1)
    exist = input.getBool(3)
    info.properties.unit = input.getBool(32)
    info.properties.trans = input.getBool(31) --peculiar property name
    if info.properties.theme  == 0 then
        info.properties.theme = property.getNumber("Theme")
        info.properties.trans = property.getBool("Transmission")
        info.properties.unit = property.getBool("Units")
    end

    --kill me
    info.speed = input.getNumber(1)
    info.gear = input.getNumber(2) -- p, r, n, (1, 2, 3, 4, 5)
    info.rps = input.getNumber(3) -- battery usage on EVs
    info.fuel = input.getNumber(4) -- battery for EVs
    info.temp = input.getNumber(5) -- gen power production on EVs
    info.gpsX = input.getNumber(6)
    info.gpsY = input.getNumber(7)
    info.compass = input.getNumber(8)*(math.pi*2)
    info.drivemode = input.getNumber(9)

    touchX = input.getNumber(10)
    touchY = input.getNumber(11)
    local touch = input.getBool(2)

    useDimDisplay = input.getBool(6)

    local clock = input.getNumber(13)

    if clock ~= lastClock then
        lastClock = clock
        if input.getBool(32) then
            clockstr = ("%02d"):format(math.floor(clock * 24) % 12) .. ":" .. ("%02d"):format(math.floor((clock * 1440) % 60))
            if string.sub(clockstr, 1, 2) == "00" then
                clockstr = "12" .. string.sub(clockstr, 3, -1)
            end
        else
            clockstr = ("%02d"):format(math.floor(clock * 24)) .. ":" .. ("%02d"):format(math.floor((clock * 1440) % 60))
        end
    end
        
    if not fuelCollected then
        ticks = ticks + 1
    end
    if ticks <= 20 then
        info.properties.maxfuel = input.getNumber(4) or 180
        fuelCollected = true
        ticks = 0
    end

    --map zoom
    if touch and isPointInRectangle(23, 26, 5, 5) then
        mapZoom = math.min(mapZoom + 0.1, 5)
    elseif touch and isPointInRectangle(67, 26, 5, 5) then
        mapZoom = math.max(mapZoom - 0.1, 0.5)
    end

    mapZoom = mapZoom + (info.speed / info.properties.topspeed) * 0.1
    
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
end

function onDraw()
    if exist then
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
        if info.rps>info.properties.upshift then c(180, 53, 35) else c(theme[2][1], theme[2][2], theme[2][3]) end
        drawCircle(80, 16, 10, 8, 60, dialStart, math.min(info.rps / (info.properties.upshift + 5), 1) * 230 * oneDeg) --rps

        c(theme[3][1], theme[3][2], theme[3][3])

        if info.properties.ev then
            drawCircle(16, 16, 15, 13, 60, outStart, info.fuel * 120 * oneDeg) --battery
            drawCircle(80, 16, 15, 13, 60, outStart, math.min(info.temp / 25, 1) * 120 * oneDeg, -1) --gen power production
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
    elseif not acc then
        c(100, 100, 100)
        dst(40, 10, clockstr)
        c(80, 80, 80)
        if info.properties.ev then
            dst(28, 20, "Tap to start")
        end
        dst(2, 2, "ST")
    end
end

function c(...) local _={...}
    for i,v in pairs(_) do
     _[i]=_[i]^2.2/255^2.2*_[i]
    end
    screen.setColor(table.unpack(_))
end

--dst(x,y,text,size=1,rotation=1,is_monospace=false)
--rotation can be between 1 and 4
f=screen.drawRectF
g=property.getText
--magic willy font
h=g("FONT1")..g("FONT2")
i={}j=0
for k in h:gmatch("....")do i[j+1]=tonumber(k,16)j=j+1 end
function dst(l,m,n,b,o,p)b=b or 1
o=o or 1
if o>2 then n=n:reverse()end
n=n:upper()for q in n:gmatch(".")do
r=q:byte()-31 if 0<r and r<=j then
for s=1,15 do
if o>2 then t=2^s else t=2^(16-s)end
if i[r]&t==t then
u,v=((s-1)%3)*b,((s-1)//3)*b
if o%2==1 then f(l+u,m+v,b,b)else f(l+5-v,m+u,b,b)end
end
end
if i[r]&1==1 and not p then
s=2*b
else
s=4*b
end
if o%2==1 then l=l+s else m=m+s end
end
end
end


function drawPointer(x,y,c,s)
    local d = 5
    local sin, pi, cos = math.sin, math.pi, math.cos
    screen.drawTriangleF(sin(c - pi) * s + x + 1, cos(c - pi) * s + y +1, sin(c - pi/d) * s + x +1, cos(c - pi/d) * s + y +1, sin(c + pi/d) * s + x +1, cos(c + pi/d) * s + y +1)
end

function isPointInRectangle(rectX, rectY, rectW, rectH)
	return touchX > rectX and touchY > rectY and touchX < rectX+rectW and touchY < rectY+rectH
end

function gpsSpeed(x,y,lX,lY) -- function by GOM
    s=(((x-lX)^2+(y-lY)^2)^0.5)
    return s,x,y
end

--- draws an arc around pixel coords [x], [y].
function drawCircle(x, y, outer_rad, inner_rad, step, begin_ang, arc_ang, dir)
    dir = dir or 1
    local step_s = pi2 / step * -dir
    local ba = begin_ang * dir
    local steps = math.floor(arc_ang / (pi2 / step))
    local sin, cos = math.sin, math.cos
    
    for i = 0, steps - 1 do
        local step_p = ba + step_s * i
        local step_n = ba + step_s * (i + 1)
        
        -- Cache sin/cos calculations
        local sin_p, cos_p = sin(step_p), cos(step_p)
        local sin_n, cos_n = sin(step_n), cos(step_n)
        
        local x1, y1 = x + sin_p * outer_rad, y + cos_p * outer_rad
        local x2, y2 = x + sin_n * outer_rad, y + cos_n * outer_rad
        local x3, y3 = x + sin_p * inner_rad, y + cos_p * inner_rad
        local x4, y4 = x + sin_n * inner_rad, y + cos_n * inner_rad
        
        screen.drawTriangleF(x1, y1, x2, y2, x3, y3)
        screen.drawTriangleF(x2, y2, x4, y4, x3, y3)
    end
end

function easeLerp(v0, v1, t)
    local ease = t <= 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
    return v0 + (v1 - v0) * ease
end
