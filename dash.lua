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
    simulator:setProperty("Dash Layout", 1) -- 1 - SenCar 6, 2 - SenCar 5, 3 - Round, 4 - Modern

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
        simulator:setInputBool(1, true)
        simulator:setInputBool(2, false)
        simulator:setInputBool(3, true)
        simulator:setInputBool(32, true)

        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputNumber(1, simulator:getSlider(1)*100)
        simulator:setInputNumber(2, math.floor(simulator:getSlider(2) * 7))
        simulator:setInputNumber(3, simulator:getSlider(3)*25)
        simulator:setInputNumber(4, simulator:getSlider(4))
        simulator:setInputNumber(5, simulator:getSlider(5)*120)
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
info.properties.trans = property.getBool("Transmission")
info.properties.unit = property.getBool("Units")

local usingSenconnect = property.getBool("Enable SenConnect") --disables map rendering, in favor of SenConnect's map

local dashMode = property.getNumber("Dash Layout")

function onTick()
    acc = input.getBool(1)
    exist = input.getBool(3)
    info.properties.unit = input.getBool(32)
    info.properties.trans = input.getBool(31) --peculiar property name

    touchX = input.getNumber(10)
    touchY = input.getNumber(11)
    local touch = input.getBool(2)

    
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

    if dashMode > 2 then return end
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

    useDimDisplay = input.getBool(6)
        
    if not fuelCollected then
        ticks = ticks + 1
    end
    if ticks <= 20 then
        info.properties.maxfuel = input.getNumber(4) or 180
        fuelCollected = true
        ticks = 0
    end

    --map zoom
    if dashMode == 1 then
        if touch and isPointInRectangle(26, 22, 5, 5) then
            mapZoom = math.min(mapZoom + 0.1, 5)
        elseif touch and isPointInRectangle(65, 22, 5, 5) then
            mapZoom = math.max(mapZoom - 0.1, 0.5)
        end
    elseif dashMode == 2 then
        if touch and isPointInRectangle(23, 26, 5, 5) then
            mapZoom = math.min(mapZoom + 0.1, 5)
        elseif touch and isPointInRectangle(67, 26, 5, 5) then
            mapZoom = math.max(mapZoom - 0.1, 0.5)
        end
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
        -- Heavily abusing LifeBoatAPI's ability to paste code from other files by require
        -- The two dash files literally get pasted into this function
        if dashMode == 1 then
            require("dashes.car6")
        elseif dashMode == 2 then
            require("dashes.car5")
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

function clamp(v, min, max)
    return math.min(math.max(v, min), max)
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
