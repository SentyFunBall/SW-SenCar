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
    simulator:setProperty("Transmission", true) --true for automatic
    simulator:setProperty("Units", true) --true for imperial
    simulator:setProperty("Theme", 3) --we dont have the "Use Drive Modes" property because that is handled by the transmission
    simulator:setProperty("Car name", "SenCar 5 DEV")
    simulator:setProperty("Top Speed (m/s)", 66)

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

        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputNumber(1, simulator:getSlider(1)*100)
        simulator:setInputNumber(2, math.floor(simulator:getSlider(2) * 7))
        simulator:setInputNumber(3, simulator:getSlider(3)*25)
        simulator:setInputNumber(4, simulator:getSlider(4)*181)
        simulator:setInputNumber(5, simulator:getSlider(5)*200)
        simulator:setInputNumber(8, simulator:getSlider(8))
        simulator:setInputNumber(9, simulator:getSlider(9))
        simulator:setInputNumber(10, 2)
        simulator:setInputNumber(31, screenConnection.touchX)
        simulator:setInputNumber(32, screenConnection.touchY)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

_colors = {
    {{47,51,78}, {86,67,143}, {128,95,164}}, --sencar 5 in the micro
    {{17, 15, 107}, {22, 121, 196}, {48, 208, 217}}, --blue
    {{74, 27, 99}, {124, 42, 161}, {182, 29, 224}}, --purple
    {{35, 54, 41}, {29, 87, 36}, {12, 133, 26}}, --green
    {{69, 1, 10}, {122, 0, 0}, {160, 9, 9}}, --TE red
    {{38, 38, 38}, {92, 92, 92}, {140, 140, 140}}, --grey
    {{92, 50, 1}, {158, 92, 16}, {201, 119, 24}} --orange
}

info = {properties = {}}
fuelCollected = false
remdeg = 130
ticks = 0

gears = {"P", "R", "N", "D"}

for i = #gears, 2, -1 do
    local j = math.random(i)
    gears[i], gears[j] = gears[j], gears[i]
end

passcode = math.random(1000, 9999)
unlock = false
passcodeAttempts = 0

info.properties.fuelwarn = property.getNumber("Fuel Warn %")/100
info.properties.tempwarn = property.getNumber("Temp Warn")
--info.properties.upshift = property.getNumber("Upshift RPS")
info.properties.downshift = property.getNumber("Downshift RPS")
info.properties.useDriveModes = property.getBool("Use Drive Modes")
info.properties.topspeed = property.getNumber("Top Speed (m/s)")/100
info.properties.maxfuel = 0

function onTick()
    acc = input.getBool(1)
    exist = input.getBool(3)
    usingSenconnect = input.getBool(2) --disables map rendering, in favor of SenConnect's map
    info.properties.unit = input.getBool(32)
    info.properties.theme = input.getNumber(32)
    info.properties.trans = input.getBool(31) --peculiar property name
    if info.properties.theme  == 0 then
        info.properties.theme = property.getNumber("Theme")
        info.properties.trans = property.getBool("Transmission")
        info.properties.unit = property.getBool("Units")
    end

    --kill me
    info.speed = input.getNumber(1)
    info.gear = input.getNumber(2) -- p, r, n, (1, 2, 3, 4, 5)
    info.rps = input.getNumber(3)
    info.fuel = input.getNumber(4)
    info.temp = input.getNumber(5)
    info.gpsX = input.getNumber(6)
    info.gpsY = input.getNumber(7)
    info.compass = input.getNumber(8)*(math.pi*2)
    info.drivemode = input.getNumber(9)
    info.properties.upshift = property.getNumber("Upshift RPS")
    info.passcodeAttempt = input.getNumber(10)

    if info.passcodeAttempt ~= oldPasscodeAttempt then
        if info.passcodeAttempt == passcode then
            unlock = true
        else
            passcodeAttempts = passcodeAttempts + 1
        end
    end

    if passcodeAttempts == 3 then --trigger alarm
        output.setBool(1, true)
    end

    if not fuelCollected then
        ticks = ticks + 1
    end
    if ticks == 20 then
        info.properties.maxfuel = input.getNumber(4) or 180
        fuelCollected = true
        ticks = 0
    end

    oldPasscodeAttempt = info.passcodeAttempt
end

function onDraw()
    if acc and unlock then
        local _ = _colors[info.properties.theme]

        if ((not usingSenconnect) and info.gear ~= 1) then --dont draw map if were in reverse or if SC is connected (haha magic boolean)
            --screenX, screenY = map.screenToMap(info.gpsX, info.gpsY, 2, 96, 32, 58, 25)
            screen.drawMap(info.gpsX, info.gpsY, 2)
            --map icon
            c(_[3][1], _[3][2], _[3][3])
            drawPointer(48,16,info.compass, 5)
        end

        for i=0, 47 do
            c(_[1][1], _[1][2], _[1][3], lerp(255, 50, i/47))
            screen.drawLine(i, 0, i, 32)
            screen.drawLine(96-i, 0, 96-i, 32)
        end
        
        -- circles
        c(_[1][1], _[1][2], _[1][3],250) --i love tables
        screen.drawCircleF(16, 16, 12)
        screen.drawCircleF(80, 16, 12)

        -- empter dials
        c(_[1][1]-15, _[1][2]-15, _[1][3]-15)
        drawCircle(16, 16, 10, 8, 60, -remdeg/2*math.pi/180, (360-remdeg)*math.pi/180) --speed
        drawCircle(80, 16, 10, 8, 60, -remdeg/2*math.pi/180, (360-remdeg)*math.pi/180) --rps
        drawCircle(16, 16, 15, 13, 60, remdeg/5*math.pi/180, (250-remdeg)*math.pi/180) --fuel
        drawCircle(80, 16, 15, 13, 60, remdeg/5*math.pi/180, (250-remdeg)*math.pi/180, -1) --temp

        -- labels (credit to mrlennyn for the ui builder (fuck off copilot i thought i uninstalled you))
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

        --- fuel
        if info.fuel/info.properties.maxfuel < info.properties.fuelwarn then
            c(150,50,50)
        else
            c(150,150,150)
        end
        screen.drawRectF(1,29,3,2)
        screen.drawRect(1,26,2,2)
        screen.drawLine(5,27,5,31)
        screen.drawRectF(4,29,1,1)
        screen.drawRectF(4,26,1,1)

        if info.properties.useDriveModes then
            --- drive modes
            if info.drivemode == 1 then --eco
                c(_[2][1], _[2][2], _[2][3])
                screen.drawText(41,2,"Eco")
            elseif info.drivemode == 2 then --sport
                c(_[2][1], _[2][2], _[2][3])
                screen.drawText(36,2,"Sport")
            elseif info.drivemode == 3 then --tow
                c(_[2][1], _[2][2], _[2][3])
                screen.drawText(41,2,"Tow")
            elseif info.drivemode == 4 then --dac
                c(_[2][1], _[2][2], _[2][3])
                screen.drawText(41,2,"DAC")
            end
        end

        --[[ battery meter (hiding this for later use in WidgetAPI)
        c(_[1][1], _[1][2], _[1][3])


        c(_[1][1], _[1][2], _[1][3])
        dl(1,4,1,7)
        dl(5,4,5,6)
        dl(9,4,9,7)

        c(_[3][1], _[3][2], _[3][3])
        dl(0,5,info.battery*9,5)]]

        -- dial that fills up
        c(_[2][1], _[2][2], _[2][3])
        drawCircle(16, 16, 10, 8, 60, -remdeg/2*math.pi/180, math.min(info.speed/100/info.properties.topspeed, 1)*(360-remdeg)*math.pi/180) --speed
        if info.rps>info.properties.upshift then c(180, 53, 35) else c(_[2][1], _[2][2], _[2][3]) end
        drawCircle(80, 16, 10, 8, 60, -remdeg/2*math.pi/180, math.min(info.rps/(info.properties.upshift+5), 1)*(360-remdeg)*math.pi/180) --rps

        c(_[3][1], _[3][2], _[3][3])
        drawCircle(16, 16, 15, 13, 60, remdeg/5*math.pi/180, math.min(info.fuel/info.properties.maxfuel, 1)*(250-remdeg)*math.pi/180) --fuel, should clamp within fuel we got in 20th tick as max fuel
        drawCircle(80, 16, 15, 13, 60, remdeg/5*math.pi/180, math.min(info.temp/110, 1)*(250-remdeg)*math.pi/180, -1) --temp, clamps within -inf and 120

        --text
        -- speed
        c(200,200,200)
        if info.properties.unit then
            mph = math.floor(info.speed * 2.23)
            if mph < 10 then
                screen.drawText(14, 12, string.format("%.0f", mph))
                --dst(13,9,string.format("%.0f", mph),2)
            elseif mph < 100 then
                screen.drawText(12, 12, string.format("%.0f",mph))
                --dst(10,9,string.format("%.0f", mph),2)
            else
                screen.drawText(9, 12,string.format("%.0f", mph))
                --dst(8,9,string.format("%.0f", mph),1.6)
            end
            c(150,150,150)
            dst(11, 20, "mph")
        else
            c(200,200,200)
            kph = math.floor(info.speed * 3.6)
            if kph < 10 then
                screen.drawText(14, 12, string.format("%.0f", kph))
                --dst(13,9,string.format("%.0f", mph),2)
            elseif kph < 100 then
                screen.drawText(12, 12, string.format("%.0f",kph))
                --dst(10,9,string.format("%.0f", mph),2)
            else
                screen.drawText(9, 12,string.format("%.0f", kph))
                --dst(8,9,string.format("%.0f", mph),1.6)
            end
            c(150,150,150)
            dst(11, 20, "kph")
        end
        c(200,200,200)
        
        -- gear
        if info.gear == 0 then
            dst(78,9,gears[1],2)
        elseif info.gear == 1 then
            dst(78,9,gears[2],2)
        elseif info.gear == 2 then
            dst(78,9,gears[3],2)
        elseif info.gear >= 3 then
            if info.properties.trans then --auto
                dst(77,9,gears[4],2)
                dst(84,13,string.format("%.0f", info.gear-2))
            else
                dst(78,9,string.format("%.0f", info.gear-2),2)
            end
        end

        -- units
        c(150,150,150)
        if info.properties.trans then
            dst(73,20,"auto")
        else
            dst(75,20,"man")
        end
        --dst(76, 1, "rps", 0.8)
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

--- draws an arc around pixel coords [x], [y]
---@param x number number The X coordinate of the center of the arc
---@param y number The Y coordinate of the center of the arc
---@param outer_rad number The distance from the outer edge of the arc to the center of the arc. AKA Radius
---@param inner_rad number The distance from the inner edge of the arc to the center of the arc. Set to 0 to make a circle
---@param step number The amount of triangles to draw the entire arc. Step size does not stay constant, and may vary with arc_ang
---@param begin_ang number Beginning angle of the arc in radians
---@param arc_ang number Angle of the entire arc in radians
---@param dir number Direction of the arc. Default 1, -1 for reverse.
function drawCircle(x,y,outer_rad, inner_rad, step, begin_ang, arc_ang, dir)
  dir = dir or 1
  sin=math.sin cos=math.cos pi=math.pi pi2=math.pi*2
  step_s=pi2/step*-dir
  ba=begin_ang*dir
  ora=outer_rad
  ira=inner_rad
  for i=0, math.floor(arc_ang / (pi2 / step))-1 do
    step_p=ba+step_s*i
    step_n=ba+step_s*(i+1)
    screen.drawTriangleF(x+sin(step_p)*ora, y+cos(step_p)*ora, x+sin(step_n)*ora, y+cos(step_n)*ora, x+sin(step_p)*ira, y+cos(step_p)*ira)
    screen.drawTriangleF(x+sin(step_n)*ora, y+cos(step_n)*ora, x+sin(step_n)*ira, y+cos(step_n)*ira, x+sin(step_p)*ira, y+cos(step_p)*ira)
  end
end

function lerp(v0,v1,t)
    return v1*t+v0*(1-t)
end