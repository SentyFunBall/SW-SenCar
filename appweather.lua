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
        simulator:setInputNumber(5, simulator:getSlider(1) - 0.5)
        simulator:setInputNumber(10, simulator:getSlider(2)-0.5)

        simulator:setInputNumber(3, 1)
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

scrollPixels = 0
conditions = "Sunny"
showInfo = false

function onTick()
    acc = input.getBool(1)
    theme = input.getNumber(32)
if theme == 0 then
theme = property.getNumber("Theme")
end
    units = input.getBool(32)

    touchX = input.getNumber(1)
    touchY = input.getNumber(2)

    press = input.getBool(3) and press + 1 or 0
    app = input.getNumber(3)

    rain = input.getNumber(4)
    fog = input.getNumber(7)
    clock = input.getNumber(8)
    temp = input.getNumber(9)

    if app == 1 then --eather
        if press > 0 and isPointInRectangle(touchX, touchY, 0, 18, 12, 19) then --up
            scrollPixels = clamp(scrollPixels-2, 0, 10000) --honestly, the max value is arbitrary
            zoomin = true
        else
            zoomin = false
        end
        if press > 0 and isPointInRectangle(touchX, touchY, 0, 39, 12, 19) then --down
            if 108 - scrollPixels > 64 then
                scrollPixels = scrollPixels + 2
            end
            zoomout = true
        else
            zoomout = false
        end
        if press == 2 and isPointInRectangle(touchX, touchY, 14, 97 - scrollPixels, 80, 10) then showInfo = not showInfo end

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
    local _ = _colors[theme]
    if acc then

----------[[* MAIN OVERLAY *]]--

        if app == 1 then
            c(table.unpack(color))
            screen.drawRectF(0, 0, 96, 64)

            hcolor = {200, 200, 200}
            rcolor = {150, 150, 150}
            tcolor = {50, 50, 50}
            if not showInfo then
                c(table.unpack(hcolor))
                screen.drawText(15, 16-scrollPixels, "Current weather")
                c(100,100,100)
                screen.drawLine(15,23-scrollPixels,80,23-scrollPixels)
                drawInfo(15, 26-scrollPixels, "Conditions", conditions, hcolor, rcolor, tcolor)
                drawInfo(15 ,43-scrollPixels, "Temperature", temp, hcolor, rcolor, tcolor)
                drawInfo(15, 60-scrollPixels, "Rain", rain, hcolor, rcolor, tcolor)
                drawInfo(15, 77-scrollPixels, "fog", string.format("%.0f%%", fog*100), hcolor, rcolor, tcolor)
            else
                c(50,50,50)
                screen.drawTextBox(15, 16-scrollPixels, 80, 1000, "Wind data not presented due to vehicle speeds preventing accurate data measurements. We do not want to use third-party addons, so instead we try to provide you with the best weather app.", -1, -1)
            end
            c(100,100,100)
            screen.drawLine(15,94-scrollPixels,80,94-scrollPixels)
            drawFullToggle(15, 97-scrollPixels, showInfo, "Disclaimer", rcolor, tcolor)
        end

----------[[* CONTROLS OVERLAY *]]--
        c(_[1][1], _[1][2], _[1][3], 250)
        screen.drawRectF(0, 15, 13, 64)

        if app == 1 then
            if zoomin then c(150,150,150) else c(170, 170, 170)end
            drawRoundedRect(1, 19, 10, 18)
            if zoomout then c(150,150,150) else c(170, 170, 170)end
            drawRoundedRect(1, 40, 10, 18)
            c(100,100,100)
            screen.drawTriangleF(3, 29, 6, 25, 10, 29)
            screen.drawTriangleF(2, 48, 6, 53, 11, 48)
        end
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

--dst(x,y,text,size=1,rotation=1,is_monospace=false)
--rotation can be between 1 and 4
--[[f=screen.drawRectF
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
end]]