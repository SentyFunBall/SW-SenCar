--appsettings
-- Author: SentyFunBall
-- GitHub: https://github.com/SentyFunBall
-- Workshop:

--Code by ST. Do not reuse.--
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
    simulator:setProperty("Transmission", true)

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
open = false
maxScroll = 0
beforeRainbow = defaultTheme --which theme it was before setting rainbow mode
lastRainbowMode = false

themes = {
    "Default",
    "Blue",
    "purple",
    "green",
    "TE red",
    "Grey",
    "Orange"
}

actions = { --action {"name", state, type (0=toggle,1=dropdown,2=slider), isShow, extra}
    { "Metric",      false, 0 },
    { "Manual",      false, 0 },
    { "ESC Off",     false, 0 },
    { "RGB Mode",    false, 0 },
    { "Hue adjust",  0,     2, { n = -180, m = 180, v = 0, s = 1 } },
    { "Gradient Res",0,     2, { n = 1, m = 9, v = 3, s = 0.1} },
    { "Theme",       0,     1, themes},
}
actionHeightOffsets = {}
total = 0
for index, action in pairs(actions) do
    local height = 0
    if action[3] == 0 then
        height = 11
        total = total + height
    elseif action[3] == 1 then
        height = 11
        total = total + height
    elseif action[3] == 2 then
        height = 19
        total = total + height
    end
    actionHeightOffsets[index] = total
end

actions[1][2] = not property.getBool("Units")
actions[2][2] = not property.getBool("Transmission")
actions[5][2] = defaultTheme
theme = _colors[defaultTheme]

function onTick()
    acc = input.getBool(1)
    app = input.getNumber(3)

    touchX = input.getNumber(1)
    touchY = input.getNumber(2)
    press = input.getBool(3) and press + 1 or 0

    lock = input.getBool(4)

    if app == 5 then --die
        maxScroll = open and 176 or 120 --adjust max scroll if dropdown is open
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

        --action inputs
        for i, action in pairs(actions) do
            if not lock then
                scrollable = 15 - scrollPixels + actionHeightOffsets[i]
                if action[3] == 0 and press == 2 and isPointInRectangle(14, 15 - scrollPixels + actionHeightOffsets[i], 80, 8) then --toggle
                    action[2] = not action[2]
                elseif action[3] == 1 and press == 2 then --dropdown
                    if isPointInRectangle(14, scrollable, 80, 8) then
                        open = not open
                    end

                    --select themes
                    for j = 1, #themes do
                        if open and isPointInRectangle(14, scrollable + #themes * j + j, 80, 8) then
                            theme = _colors[j]
                            beforeRainbow = j
                            actions[5][4].v = 0
                            open = false
                        end
                    end
                elseif action[3] == 2 and press > 1 then --slider
                    --down
                    if isPointInRectangle( 14, scrollable, 8, 8) then
                        action[4].v = clamp(action[4].v - action[4].s, action[4].n, action[4].m)
                    end
                    --up
                    if isPointInRectangle(77, scrollable, 8, 8) then
                        action[4].v = clamp(action[4].v + action[4].s, action[4].n, action[4].m)
                    end
                end
            end
        end
    end

    --theme adjustments
    tempTheme = rgbToHsv(theme)
    hsvTheme = rgbToHsv(_colors[beforeRainbow])

    if actions[4][2] then --RGB mode
        lastRainbowMode = true
        for _, set in pairs(tempTheme) do
            set[1] = (set[1] + 0.003) % 1
        end
    else
        if lastRainbowMode then
            lastRainbowMode = false
            tempTheme = hsvTheme
        end
        for i, set in ipairs(hsvTheme) do
            set[1] = (set[1] + actions[5][4].v / 1200) % 1
            tempTheme[i] = set
        end
    end

    theme = hsvToRgb(tempTheme)

    --output
    for i = 1, 4 do
        output.setBool(i, not actions[i][2])
    end
    output.setNumber(1, math.floor(actions[6][4].v))
    channel = 24
    for i = 1, 3 do
        for j = 1, 3 do
            output.setNumber(channel, theme[i][j])
            channel = channel + 1
        end
    end
end

function onDraw()
    if acc and app == 5 then
        --[[* MAIN OVERLAY *]] --
        c(70, 70, 70)
        screen.drawRectF(0, 0, 96, 64)

        hcolor = { theme[2][1] + 25, theme[2][2] + 25, theme[2][3] + 25 }
        c(table.unpack(hcolor))
        screen.drawText(15, 16 - scrollPixels, "Settings")
        c(100, 100, 100)
        scrollable = 23 - scrollPixels
        screen.drawLine(15, scrollable, 80, scrollable)

        --draw each action
        for i, action in pairs(actions) do
            scrollable = 15 - scrollPixels + actionHeightOffsets[i]
            if action[3] == 0 then     --toggle
                drawFullToggle(15, scrollable, action[2], action[1], theme[3], theme[1])
            elseif action[3] == 1 then --dropdown
                drawDropdown(15, scrollable, open, action[1], action[4], theme, theme[3], theme[1])
            elseif action[3] == 2 then --slider
                drawSlider(15, scrollable - 8, action[1], action[4].v, action[4].n, action[4].m, theme[3], theme[1])
            end
        end

        --[[* CONTROLS OVERLAY *]] --
        c(theme[1][1], theme[1][2], theme[1][3], 250)
        screen.drawRectF(0, 15, 13, 64)

        if scrollUp then c(150, 150, 150) else c(170, 170, 170) end
        drawRoundedRect(1, 19, 10, 18)
        if scrollDown then c(150, 150, 150) else c(170, 170, 170) end
        drawRoundedRect(1, 40, 10, 18)
        c(100, 100, 100)
        screen.drawTriangleF(3, 29, 6, 25, 10, 29)
        screen.drawTriangleF(2, 48, 6, 53, 11, 48)
    end
end

function c(...) 
    _ = {...} 
    for i, v in pairs(_) do
        _[i] = v ^ 2.2 / 255 ^ 2.2 * v
    end
    screen.setColor(table.unpack(_))
end

function clamp(v, l, u)
    return math.min(math.max(v, l), u)
end

function isPointInRectangle(rx, ry, rw, rh)
    return touchX > rx and touchY > ry and touchX < rx + rw and touchY < ry + rh
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
    width = #title * 5 + 20
    c(table.unpack(bgcolor))
    drawRoundedRect(x, y, width, open and #content * 9 or 8)

    c(table.unpack(tcolor))
    screen.drawText(x + 9, y + 2, title)
    screen.drawText(x + 2, y + 2, open and "-" or "+")
    screen.drawLine(x + 7, y, x + 7, y + 9)

    if open then
        screen.drawLine(x, y + 8, x + width + 1, y + 8)
        for i = 1, #content do
            screen.drawText(x + 2, y + 2 + i * 8, content[i])
            if current == i then
                c(50, 50, 50, 200)
                screen.drawRectF(x, y + 1 + i * 8, width + 1, 7)
            end
        end
    end
end

function drawSlider(x, y, title, value, min, max, bgcolor, tcolor)
    map = 10 + ((value - min) * ((60 - 10) / (max - min)))
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
    screen.drawLine(x + 10, y + 12, x + map, y + 12)
end

function rgbToHsv(theme) --GUESS what this does
    converted = {}
    for _, set in pairs(theme) do
        r, g, b = set[1] / 255, set[2] / 255, set[3] / 255
        max, min, d = math.max(r, g, b), math.min(r, g, b), math.max(r, g, b) - math.min(r, g, b)
        h, s, v = 0, (max == 0 and 0 or d / max), max
        if max ~= min then
            h = (max == r and (g - b) / d + (g < b and 6 or 0)) or (max == g and (b - r) / d + 2) or (max == b and (r - g) / d + 4)
            h = h / 6
        end
        converted[#converted+1] = {h, s, v}
    end
    return converted
end

function hsvToRgb(theme)
    converted = {}
    for _, set in pairs(theme) do
        h, s, v = set[1], set[2], set[3]
        i, f = math.floor(h * 6), h * 6 - math.floor(h * 6)
        p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
        i = i % 6
        r, g, b = (i == 0 and v or i == 1 and q or i == 2 and p or i == 3 and p or i == 4 and t or v),
                  (i == 0 and t or i == 1 and v or i == 2 and v or i == 3 and q or i == 4 and p or p),
                  (i == 0 and p or i == 1 and p or i == 2 and t or i == 3 and v or i == 4 and v or q)
        converted[#converted+1] = {r*255, g*255, b*255}
    end
    return converted
end
