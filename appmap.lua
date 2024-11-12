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
    simulator:setProperty("FONT1", "00019209B400AAAA793CA54A555690015244449415500BA0004903800009254956D4592EC54EC51C53A4F31C5354E52455545594104110490A201C7008A04504")
    simulator:setProperty("FONT2", "FFFE57DAD75C7246D6DCF34EF3487256B7DAE92E64D4975A924EBEDAF6DAF6DED74856B2D75A711CE924B6D4B6A4B6FAB55AB524E54ED24C911264965400000E")

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

        simulator:setInputNumber(3, 2)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

theme = {}
zoom = 3
mx, my = 0,0
wx, wy = 0,0

function onTick()
    acc = input.getBool(1)
    app = input.getNumber(3)
    units = input.getBool(32)

    touchX = input.getNumber(1)
    touchY = input.getNumber(2)
    press = input.getBool(3) and press + 1 or 0

    x = input.getNumber(4)
    y = input.getNumber(5)
    compass = input.getNumber(6)*(math.pi*2)

    --input theme
    for i = 1, 9 do
        row = math.ceil(i/3)
        if not theme[row] then theme[row] = {} end
        theme[row][(i-1)%3+1] = input.getNumber(i+23)
    end
    if theme[1][1] == 0 then --fallback
        theme = {{47,51,78}, {86,67,143}, {128,95,164}}
    end


    if app == 2 then --maps
        if press > 0 and isPointInRectangle(0, 18, 12, 12) then zoom = clamp(zoom - 0.01 - press/800, 0.3, 25) zoomin = true else zoomin = false end --zoomin
        if press > 0 and isPointInRectangle(0, 30, 12, 12) then zoom = clamp(zoom + 0.01 + press/800, 0.3, 25) zoomout = true else zoomout = false end --zoomout
        if press > 0 and isPointInRectangle(0, 42, 12, 12) then zoom = 3 mx,my = 0,0 resetbtn = true else resetbtn = false end --reset
        if press == 2 and isPointInRectangle(0, 52, 12, 12) then if wx == 0 then wx,wy = ax,ay else wx,wy = 0,0 end wbtn = true else wbtn = false end --waypoint
        if press > 0 and isPointInRectangle(12, 14, 96, 64) then mapt = true else mapt = false end --map touch
    end
end

function onDraw()
    if acc and app == 2 then
----------[[* MAIN OVERLAY *]]--
        if mx == 0 then ax = x else ax = mx end --actual X
        if my == 0 then ay = y else ay = my end --actual Y
        if press == 2 and isPointInRectangle(touchX, touchY, 15, 13, 96, 64) then mx, my = map.screenToMap(ax, ay, zoom, 96, 64, touchX, touchY) end --masterX, masterY

        screen.drawMap(ax, ay, zoom)

        c(theme[2][1], theme[2][2], theme[2][3])
        screen.drawCircle(48, 32, 1)
        dx, dy = map.mapToScreen(ax, ay, zoom, 96, 64, x, y) --drawX, drawY 
        drawPointer(dx, dy, compass, 5)

        if wx ~= 0 then --if waypoint is active
            -- find waypoint coords and draw the line from player to it
            dx2,dy2 = map.mapToScreen(ax,ay, zoom, 96, 64, wx, wy)
            screen.drawLine(dx2, dy2, dx, dy)

            --draw the waypoint
            c(theme[3][1], theme[3][2], theme[3][3])
            screen.drawCircle(dx2,dy2,1)

            --find midpoint of line and draw distance in box
            c(200,200,200)
            sx, sy = (dx+dx2)/2, (dy+dy2)/2 --averageX, averageY
            tempx, tempy = map.screenToMap(ax, ay, zoom, 96, 64, dx, dy)
            tempx2, tempy2 = map.screenToMap(ax, ay, zoom, 96, 64, dx2, dy2)
            dist = math.sqrt((tempx2 - tempx)*(tempx2 - tempx) + (tempy2 - tempy)*(tempy2 - tempy)) --should give us world distance
            dist = dist/1000
            if zoom < dist * 4 then 
                if units then --imperial
                    text = ("%.1fmi"):format(dist/1.6)
                else-- metric
                    text = ("%.1fk"):format(dist)
                end

                drawRoundedRect(math.floor(sx-10), math.floor(sy-10), #text*5+5, 8) 
                c(theme[2][1], theme[2][2], theme[2][3])
                screen.drawText(sx-8, sy-8, text)
            end
        end

        c(theme[1][1], theme[1][2], theme[1][3], 250)
        if units then --imperial
            tx = "X:"..("%.1fmi"):format(ax/1609)
            ty = "Y:"..("%.1fmi"):format(ay/1609)
        else --metric
            tx = "X:"..("%.1fk"):format(ax/1000)
            ty = "Y:"..("%.1fk"):format(ay/1000)
        end
        drawRoundedRect(54, 46, #ty*5+5, 16)
        drawRoundedRect(14, 53, 37, 9)
        c(200, 200, 200)
        screen.drawText(55, 49, tx)
        screen.drawText(55, 55, ty)
        screen.drawLine(17,54,48,54)
        screen.drawLine(17,53,17,54)
        screen.drawLine(47,53,47,54)

        --draw the cur zoom according to the unit
        if units then
            screen.drawText(16, 56, string.format("%.2fmi", zoom/1.6))
        else
            screen.drawText(16, 56, string.format("%.2fkm", zoom))
        end

        --if the map is touched, put a light black box over it
        if mapt then
            c(0,0,0,100)
            screen.drawRectF(12,14,96,64)
        end

----------[[* CONTROLS OVERLAY *]]--
        c(theme[1][1], theme[1][2], theme[1][3], 250)
        screen.drawRectF(0, 15, 13, 64)

        --zoom icons
        if zoomin then c(150,150,150) else c(170, 170, 170)end
        drawRoundedRect(1, 16, 10, 10)
        if zoomout then c(150,150,150) else c(170, 170, 170)end
        drawRoundedRect(1,28,10,10)
        if resetbtn then c(150,150,150) else c(170, 170, 170)end
        drawRoundedRect(1,40,10,10)
        if wbtn then c(150,150,150) else c(170, 170, 170)end
        drawRoundedRect(1,52,10,10)

        c(100,100,100)
        screen.drawText(5, 43, "R")
        screen.drawLine(4, 33, 9, 33)
        screen.drawLine(4, 21, 9, 21)
        screen.drawLine(6, 19, 6, 24)
        if wx == 0 then screen.drawText(5, 55, "W") else screen.drawText(5, 55, "C") end
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

function drawPointer(x,y,c,s)
    local d = 5
    local sin, pi, cos = math.sin, math.pi, math.cos
    screen.drawTriangleF(sin(c - pi) * s + x + 1, cos(c - pi) * s + y +1, sin(c - pi/d) * s + x +1, cos(c - pi/d) * s + y +1, sin(c + pi/d) * s + x +1, cos(c + pi/d) * s + y +1)
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

function clamp(value, lower, upper)
    return math.min(math.max(value, lower), upper)
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