--appcar
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
    simulator:setProperty("FONT1",
        "00019209B400AAAA793CA54A555690015244449415500BA0004903800009254956D4592EC54EC51C53A4F31C5354E52455545594104110490A201C7008A04504")
    simulator:setProperty("FONT2",
        "FFFE57DAD75C7246D6DCF34EF3487256B7DAE92E64D4975A924EBEDAF6DAF6DED74856B2D75A711CE924B6D4B6A4B6FAB55AB524E54ED24C911264965400000E")
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

        simulator:setInputNumber(3, 5)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

_colors = {
    { { 47, 51, 78 },  { 86, 67, 143 },  { 128, 95, 164 } }, --sencar 5 in the micro
    { { 17, 15, 107 }, { 22, 121, 196 }, { 48, 208, 217 } }, --blue
    { { 74, 27, 99 },  { 124, 42, 161 }, { 182, 29, 224 } }, --purple
    { { 35, 54, 41 },  { 29, 87, 36 },   { 12, 133, 26 } },  --green
    { { 69, 1, 10 },   { 122, 0, 0 },    { 160, 9, 9 } },    --TE red
    { { 38, 38, 38 },  { 92, 92, 92 },   { 140, 140, 140 } }, --grey
    { { 92, 50, 1 },   { 158, 92, 16 },  { 201, 119, 24 } }  --orange
}

scrollPixels = 0
defaultTheme = property.getNumber("Theme")
units = property.getBool("Units")
def = property.getBool("Transmission")
open = false
maxscroll = 0

--action {"name", state, type (0=toggle,1=dropdown,2=slider), isShow, extra}
themes = {
    "Default",
    "blue",
    "purple",
    "green",
    "TE red",
    "Grey",
    "Orange"
}
actions = {
    { "Metric",      false, 0 },
    { "Manual",      false, 0 },
    { "SenConnect",  true,  0 },
    { "RGB Mode",    false, 0 },
    { "Hue hue hue", 0,     2, { min = -180, max = 180, value = 0 } },
    { "Theme",       0,     1, themes },
}

actions[1][2] = not units
actions[2][2] = not def
actions[5][2] = defaultTheme
theme = _colors[defaultTheme]

function onTick()
    touchX = input.getNumber(1)
    touchY = input.getNumber(2)

    press = input.getBool(3) and press + 1 or 0
    app = input.getNumber(3)

    if app == 5 then --die
        if open then --adjust max scroll if dropdown is open
            maxScroll = 155
        else
            maxScroll = 100
            if scrollPixels > maxScroll - 64 then
                scrollPixels = maxScroll - 64
            end
        end
        --scroll
        if press > 0 and isPointInRectangle(touchX, touchY, 0, 18, 12, 19) then --up
            scrollPixels = clamp(scrollPixels - 2, 0, 9999)                     --honestly, the max value is arbitrary
            zoomin = true
        else
            zoomin = false
        end
        if press > 0 and isPointInRectangle(touchX, touchY, 0, 39, 12, 19) then --down
            if maxScroll - scrollPixels > 64 then
                scrollPixels = scrollPixels + 2
            end
            zoomout = true
        else
            zoomout = false
        end

        --action inputs
        for i, action in pairs(actions) do
            if action[3] == 0 then --toggle
                if press == 2 and isPointInRectangle(touchX, touchY, 15, 15 - scrollPixels + i * 11, 80, 8) then
                    action[2] = not action[2]
                end
            elseif action[3] == 1 then --dropdown
                if press == 2 and isPointInRectangle(touchX, touchY, 15, 23 - scrollPixels + i * 11, 80, 8) then
                    open = not open
                end
                --select themes
                for j = 1, #action[4] do
                    if press == 2 and open and isPointInRectangle(touchX, touchY, 15, 23 - scrollPixels + i * 11 + #themes * j + j, 80, 8) then
                        theme = _colors[j]
                        open = not open
                    end
                end
            elseif action[3] == 2 then --slider
                -- down
                if press > 1 and isPointInRectangle(touchX, touchY, 15, 23 - scrollPixels + i * 11, 8, 8) then
                    action[4].value = clamp(action[4].value - 1, action[4].min, action[4].max)
                end
                --up
                if press > 1 and isPointInRectangle(touchX, touchY, 78, 23 - scrollPixels + i * 11, 8, 8) then
                    action[4].value = clamp(action[4].value + 1, action[4].min, action[4].max)
                end
            end
        end
    end

    --theme adjustments
    tempTheme = rgbToHsv(theme)
    if actions[4][2] then --rgb mode
        for _, set in pairs(tempTheme) do
            set[1] = set[1] + 0.003
            if set[1] > 1 then
                set[1] = 0
            end
        end
    else
        for _, set in pairs(tempTheme) do
            set[1] = set[1] + actions[5][4].value/1800
            if set[1] > 1 then
                set[1] = 0
            end
            if set[1] < 0 then
                set[1] = 1
            end
        end
    end
    theme = hsvToRgb(tempTheme)

    --output
    --[[for i = 1, #actions do
        output.setBool(i, not actions[i][2])
    end]]
end

function onDraw()
    local _ = theme
    if app == 5 then
        --[[* MAIN OVERLAY *]] --
        c(70, 70, 70)
        screen.drawRectF(0, 0, 96, 64)

        hcolor = { _[2][1] + 25, _[2][2] + 25, _[2][3] + 25 }
        rcolor = { _[3][1], _[3][2], _[3][3] }
        tcolor = { _[1][1], _[1][2], _[1][3] }
        c(table.unpack(hcolor))
        screen.drawText(15, 16 - scrollPixels, "OS options")
        c(100, 100, 100)
        screen.drawLine(15, 23 - scrollPixels, 80, 23 - scrollPixels)

        --draw each action
        --[[for i=1, #actions do
            drawFullToggle(15, 15-scrollPixels+i*11, actions[i][2], actions[i][1], rcolor, tcolor)
        end
        if not actions[4][2] then
            drawDropdown(15, 26-scrollPixels+#actions*11, open, "Theme \\/", themes, theme, rcolor, tcolor)
        end]]
        for i, action in pairs(actions) do
            if action[3] == 0 then     --toggle
                drawFullToggle(15, 15 - scrollPixels + i * 11, action[2], action[1], rcolor, tcolor)
            elseif action[3] == 1 then --dropdown
                drawDropdown(15, 23 - scrollPixels + i * 11, open, action[1], action[4], theme, rcolor, tcolor)
            elseif action[3] == 2 then --slider
                drawSlider(15, 15 - scrollPixels + i * 11, action[1], action[4].value, action[4].min, action[4].max,
                    rcolor, tcolor)
            end
        end

        --[[* CONTROLS OVERLAY *]] --
        c(_[1][1], _[1][2], _[1][3], 250)
        screen.drawRectF(0, 15, 13, 64)

        if zoomin then c(150, 150, 150) else c(170, 170, 170) end
        drawRoundedRect(1, 19, 10, 18)
        if zoomout then c(150, 150, 150) else c(170, 170, 170) end
        drawRoundedRect(1, 40, 10, 18)
        c(100, 100, 100)
        screen.drawTriangleF(3, 29, 6, 25, 10, 29)
        screen.drawTriangleF(2, 48, 6, 53, 11, 48)
    end
end

function c(...)
    local _ = { ... }
    for i, v in pairs(_) do
        _[i] = _[i] ^ 2.2 / 255 ^ 2.2 * _[i]
    end
    screen.setColor(table.unpack(_))
end

function clamp(value, lower, upper)
    return math.min(math.max(value, lower), upper)
end

function isPointInRectangle(x, y, rectX, rectY, rectW, rectH)
    return x > rectX and y > rectY and x < rectX + rectW and y < rectY + rectH
end

function drawInfo(x, y, header, text, hcolor, rcolor, tcolor) --function to draw some info with a header and a rounded rect
    c(table.unpack(hcolor))
    screen.drawText(x, y, header)
    c(table.unpack(rcolor))
    drawRoundedRect(x, y + 6, #text * 5 + 2, 8)
    c(table.unpack(tcolor))
    screen.drawText(x + 2, y + 8, text)
end

function drawRoundedRect(x, y, w, h)
    screen.drawRectF(x + 1, y + 1, w - 1, h - 1)    --body
    screen.drawLine(x + 2, y, x + w - 1, y)         --top
    screen.drawLine(x, y + 2, x, y + h - 1)         --left
    screen.drawLine(x + w, y + 2, x + w, y + h - 1) --right
    screen.drawLine(x + 2, y + h, x + w - 1, y + h) --bottom
end

function drawToggle(x, y, state)
    if state then
        c(100, 200, 100)
        screen.drawLine(x + 1, y, x + 7, y)
        screen.drawLine(x, y + 1, x + 6, y + 1)
        screen.drawLine(x + 1, y + 2, x + 7, y + 2)
        c(200, 200, 200)
        screen.drawLine(x + 7, y, x + 7, y + 3)
        screen.drawLine(x + 6, y + 1, x + 9, y + 1)
    else
        c(100, 100, 100)
        screen.drawLine(x + 2, y, x + 8, y)
        screen.drawLine(x + 3, y + 1, x + 9, y + 1)
        screen.drawLine(x + 2, y + 2, x + 8, y + 2)
        c(200, 200, 200)
        screen.drawLine(x + 1, y, x + 1, y + 3)
        screen.drawLine(x, y + 1, x + 3, y + 1)
    end
end

function drawFullToggle(x, y, state, text, bgcolor, tcolor)
    c(table.unpack(bgcolor))
    drawRoundedRect(x, y, #text * 5 + 15, 8)
    drawToggle(x + #text * 5 + 5, y + 3, state)
    c(table.unpack(tcolor))
    screen.drawText(x + 2, y + 2, text)
end

function drawDropdown(x, y, open, title, content, current, bgcolor, tcolor)
    c(table.unpack(bgcolor))
    if not open then
        drawRoundedRect(x, y, #title * 5 + 20, 8)
        c(table.unpack(tcolor))
        screen.drawText(x + 9, y + 2, title)
        screen.drawText(x + 2, y + 2, "+")
        screen.drawLine(x + 7, y, x + 7, y + 9)
    else
        drawRoundedRect(x, y, #title * 5 + 20, #content * 9)
        c(table.unpack(tcolor))
        screen.drawLine(x, y + 8, x + #title * 5 + 21, y + 8)
        screen.drawText(x + 9, y + 2, title)
        screen.drawText(x + 2, y + 2, "-")
        screen.drawLine(x + 7, y, x + 7, y + 9)

        for i = 1, #content do
            c(table.unpack(tcolor))
            screen.drawText(x + 2, y + 2 + i * 8, content[i])
            if current == i then
                c(50, 50, 50, 200)
                screen.drawRectF(x, y + 1 + i * 8, #title * 5 + 21, 7)
            end
        end
    end
end

function drawSlider(x, y, title, value, min, max, bgcolor, tcolor)
    c(table.unpack(bgcolor))
    drawRoundedRect(x, y, 70, 16)
    c(table.unpack(tcolor))
    screen.drawText(x + 2, y + 2, title)
    screen.drawText(x + 2, y + 10, "-")
    screen.drawText(x + 65, y + 10, "+")
    screen.drawLine(x + 7, y + 9, x + 7, y + 16)
    screen.drawLine(x + 62, y + 9, x + 62, y + 16)

    screen.drawLine(x + 10, y + 12, x + 60, y + 12)
    c(100, 200, 100)
    map = 10 + ((value - min) * ((60 - 10) / (max - min)))
    screen.drawLine(x + 10, y + 12, x + map, y + 12)
end

function rgbToHsv(theme) --GUESS what this does
    converted = {}
    for _, set in pairs(theme) do
        r, g, b = set[1] / 255, set[2] / 255, set[3] / 255
        max, min = math.max(r, g, b), math.min(r, g, b)
        h, s, v = 0, 0, 0
        v = max

        d = max - min
        if max == 0 then s = 0 else s = d / max end

        if max == min then
            h = 0 -- achromatic
        else
            if max == r then
                h = (g - b) / d
                if g < b then h = h + 6 end
            elseif max == g then
                h = (b - r) / d + 2
            elseif max == b then
                h = (r - g) / d + 4
            end
            h = h / 6
        end
        converted[#converted+1] = {h,s,v}
    end

    return converted
end

function hsvToRgb(theme) --modified, original function not mine
    converted = {}
    for _,set in pairs(theme) do
        h,s,v = set[1], set[2], set[3]
        r, g, b = 0, 0, 0

        i = math.floor(h * 6);
        f = h * 6 - i;
        p = v * (1 - s);
        q = v * (1 - f * s);
        t = v * (1 - (1 - f) * s);

        i = i % 6

        if i == 0 then
            r, g, b = v, t, p
        elseif i == 1 then
            r, g, b = q, v, p
        elseif i == 2 then
            r, g, b = p, v, t
        elseif i == 3 then
            r, g, b = p, q, v
        elseif i == 4 then
            r, g, b = t, p, v
        elseif i == 5 then
            r, g, b = v, p, q
        end
        converted[#converted+1] = {r*255,g*255,b*255}
    end

    return converted
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
