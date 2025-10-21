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

theme = {}

--myWidget = {id = 0, drawn = false, {content = "Batt", x = 0, y = 0, [h = false, color = {100, 100, 100}]}, {content = 0, x = 0, y = 6, [h = false, color = {10, 10, 10}]}
batteryWidget = {id = 0, drawn = false, 
    {content = "Batt", x = 1, y = 1, h = false, color = {200, 200, 200}}, 
    {content = 0, x = 1, y = 8, h = false, color = {105, 190, 124}},
    {content = 0, x = 1, y = 14, h = false, color = {105, 190, 124}}
}

weatherWidget = {id = 1, drawn = false, 
    {content = "Weather", x = 1, y = 1, h = false, color = {200, 200, 200}},
    {content = 0, x = 1, y = 8, h = false, color = {105, 190, 104}},
    {content = 0, x = 1, y = 14, h = false, color = {105, 190, 104}},
    {content = 0, x = 1, y = 20, color = {105, 190, 104}}
}

tick = 0

function onTick()
    acc = input.getBool(1)
    exist = input.getBool(2)

    units = input.getBool(32)
    battery = string.format("%.1f", input.getNumber(1)*100)
    battDelta = string.format("%.3f", input.getNumber(2)*-1000)
    rain = input.getNumber(4)

    --input theme
    for i = 1, 9 do
        row = math.ceil(i/3)
        if not theme[row] then theme[row] = {} end
        theme[row][(i-1)%3+1] = input.getNumber(i+23)
    end
    if theme[1][1] == 0 then --fallback
        theme = {{47,51,78}, {86,67,143}, {128,95,164}}
    end

    if units then
        wind = string.format("%.0fmph", input.getNumber(3)*2.237)
    else
        wind = string.format("%.0fkph", input.getNumber(3)*3.6)
    end
    if rain < 0.05 then rain = "None" elseif rain < 0.3 then rain = "Light" elseif rain < 0.7 then rain = "Medium" else rain = "Heavy" end
    fog = string.format("%.1f%%",input.getNumber(5)*100)
    if batteryWidget.drawn then
        batteryWidget[2].content = battery.."%"
        batteryWidget[3].content = battDelta
    end
    if weatherWidget.drawn then
        weatherWidget[2].content = "Rain:"..rain
        weatherWidget[3].content = "Fog:"..fog
        weatherWidget[4].content = "Wind:"..wind
    end
    if exist and tick < 1 then
        tick = tick + 0.05
    end
    if not exist and tick > 0 then
        tick = tick - 0.05
    end
end

function onDraw()
    if acc then
        for i = 1, 32 do
            c(lerp(theme[1][1], theme[2][1], i/32), lerp(theme[1][2], theme[2][2], i/32), lerp(theme[1][3], theme[2][3], i/32))
            screen.drawRectF((i * 3)-3, 0, 3, 32)
        end
        
        weatherWidget = WidgetAPI.draw(1, true, weatherWidget, {theme[2][1]+15, theme[2][2]+15, theme[2][3]+15})
        batteryWidget = WidgetAPI.draw(3, false, batteryWidget, {theme[2][1]+15, theme[2][2]+15, theme[2][3]+15})
        
        c(0,0,0,lerp(255, 1, tick))
        screen.drawRectF(0,0,96,32)
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
