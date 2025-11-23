--widgetdisplay
-- Author: SentyFunBall
-- GitHub: https://github.com/SentyFunBall
-- Workshop: <WorkshopLink>

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
    simulator:setScreen(1, "3x1")
    simulator:setProperty("Theme", 1)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.touchX)
        simulator:setInputNumber(2, screenConnection.touchY)
        simulator:setInputNumber(3, 0.94)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputBool(2, simulator:getIsToggled(2))
    end;
end
---@endsection

--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
require("APIs.WidgetAPI")

local theme = { { 47, 51, 78 }, { 86, 67, 143 }, { 128, 95, 164 } }

local color = {133, 197, 230}

--myWidget = {id = 0, drawn = false, {content = "Batt", x = 0, y = 0, [h = false, color = {100, 100, 100}]}, {content = 0, x = 0, y = 6, [h = false, color = {10, 10, 10}]}
local batteryWidget = {id = 0, drawn = false, 
    { content = "Battery",    x = 1, y = 1,  h = false, color = { 200, 200, 200 } },
    { content = "Inst Use:",  x = 1, y = 8,  h = false, color = { 105, 190, 124 } },
    { content = "Capacity:",  x = 1, y = 14, h = false, color = { 105, 190, 124 } },
    { content = "Regen:",     x = 1, y = 20, h = false, color = { 105, 190, 124 } },
}

local weatherWidget = {id = 1, drawn = false,
    { content = "Wthr",      x = 1, y = 1,  h = false, color = { 200, 200, 200 } },
    { content = "Sunny",        x = 1, y = 8,  h = false, color = { 105, 190, 124 } },
    { content = "Rng",  x = 1, y = 14, h = false, color = { 200, 200, 200 } },
    { content = "0mi",         x = 1, y = 20, h = false, color = { 100, 100, 100 } },
}

tick = 0

function onTick()
    acc = input.getBool(1)
    exist = input.getBool(2)

    local units = input.getBool(32)
    battery = input.getNumber(2)
    local rain = input.getNumber(8)
    local fog = input.getNumber(9)
    local temp = input.getNumber(10)

    local insUse = input.getNumber(7)
    local cap = input.getNumber(6)
    local regen = input.getNumber(5)

    useDimDisplay = input.getBool(31)

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

    -- Determine precipitation type and intensity
    local isSnow = temp < 5
    if rain < 0.05 then
        rain = "N/A"
    elseif rain < 0.3 then
        rain = isSnow and "Snow" or "Light"
    elseif rain < 0.7 then
        rain = isSnow and "Bad sno" or "Mod"
    else
        rain = isSnow and "Sno Stm" or "Hvy"
    end

    -- Determine weather conditions
    local isHeavyPrecip = (rain == "Hvy" or rain == "Sno Stm")
    local isAnyPrecip = rain ~= "N/A"
    local isDenselyFoggy = fog > 0.7
    local isFoggy = fog > 0.3

    if isHeavyPrecip and fog > 0.5 then
        conditions = isSnow and "Bliz" or "Storm"
        color = isSnow and {207, 207, 207} or {86, 88, 89}
    elseif isAnyPrecip then
        conditions = isSnow and "Snow" or "Rain"
        color = isSnow and {204, 206, 207} or {141, 151, 158}
    elseif isFoggy then
        if isDenselyFoggy then
            conditions = isSnow and "Fz fog" or "Fog"
            color = isSnow and {106, 119, 125} or {90, 110, 120}
        else
            conditions = isSnow and "Fz fog" or "Fog"
            color = isSnow and {106, 119, 125} or {90, 110, 120}
        end
    elseif isSnow then
        conditions, color = "Cold", {165, 242, 243}
    else
        conditions = "Clear"
        color = {135, 206, 235}
    end

    -- Estimate range lost based on weather
    local rangeLossFactor = 1.0

    if conditions == "Hvy" or conditions == "Sno Stm" then
        rangeLossFactor = rangeLossFactor - (isSnow and 0.4 or 0.3)
    elseif temp < 10 then
        rangeLossFactor = rangeLossFactor - (isSnow and 0.3 or 0.2)
    elseif isAnyPrecip then
        rangeLossFactor = rangeLossFactor - (isSnow and 0.2 or 0.05)
    end
    rangeLossFactor = math.max(110 * battery * rangeLossFactor, 0.0)
    
    -- Update widgets
    if batteryWidget.drawn then
        batteryWidget[2].content = string.format("Use:%.2fsw", insUse*60)
        batteryWidget[3].content = string.format("Cap:%.1fKW", cap/1000)
        batteryWidget[4].content = string.format("Rgn:%.0fsw", regen*2)
    end

    if weatherWidget.drawn then
        weatherWidget[2].content = conditions
        weatherWidget[2].color = color
        if units then
            weatherWidget[4].content = string.format("%.0fmi", rangeLossFactor)
        else
            weatherWidget[4].content = string.format("%.0fkm", rangeLossFactor * 1.60934)
        end
        if rangeLossFactor < 0.5 then
            weatherWidget[4].color = {255, 100, 100}
        else
            weatherWidget[4].color = {100, 255, 100}
        end
    end

    if exist and tick < 1 then
        tick = tick + 0.05
    end
    if not exist and tick > 0 then
        tick = tick - 0.05
    end
end

function onDraw()
    if not acc then return end

    for i = 1, 32 do
        c(lerp(theme[1][1], theme[2][1], i/32), lerp(theme[1][2], theme[2][2], i/32), lerp(theme[1][3], theme[2][3], i/32))
        screen.drawRectF((i * 3)-3, 0, 3, 32)
    end
    
    -- draw(slot, large, widget, bgcolor)
    batteryWidget = WidgetAPI.draw(1, true, batteryWidget, { theme[2][1] + 15, theme[2][2] + 15, theme[2][3] + 15 })
    weatherWidget = WidgetAPI.draw(3, false, weatherWidget, { theme[2][1] + 15, theme[2][2] + 15, theme[2][3] + 15 })
    
    c(0,0,0,lerp(255, 1, tick))
    screen.drawRectF(0, 0, 96, 32)
    
    if useDimDisplay then
        screen.setColor(0, 0, 0, 150)
        screen.drawRectF(0, 0, 96, 32)
    end
    
end

function c(...) local _={...}
    for i,v in pairs(_) do
     _[i]=_[i]^2.2/255^2.2*_[i]
    end
    screen.setColor(table.unpack(_))
end

function lerp(v0,v1,t)
    return v1*t+v0*(1-t)
end
