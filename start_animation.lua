--start_animation
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
    simulator:setScreen(1, "3x1")
    simulator:setProperty("Theme", 1)
    simulator:setProperty("Car name", "SenCar_5 DEV")

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, simulator:getIsToggled(1))
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

theme = {}
ticks = 0
tick = 0 --tick is lerp
done = false
function onTick()
    acc = input.getBool(1)
    car = property.getText("Car name")

    --input theme
    for i = 1, 9 do
        row = math.ceil(i/3)
        if not theme[row] then theme[row] = {} end
        theme[row][(i-1)%3+1] = input.getNumber(i+23)
    end
    if theme[1][1] == 0 then --fallback
        theme = {{47,51,78}, {86,67,143}, {128,95,164}}
    end

    if acc then
        if ticks < 160 then
            ticks = ticks + 1
        end
    else
        ticks = 0
        done = false
    end
    if ticks == 150 then
        done = true
    end

    if done and tick < 1 then
        tick = tick + 0.05
    end
    if not done and tick > 0 then
        tick = tick - 0.05
    end
    output.setBool(1, done)
    output.setNumber(1, ticks)
end

function onDraw()
    if acc and ticks < 155 then
        drawGradient(ticks)
        alpha = lerp(0, 220, ticks/160)
        c(theme[2][1], theme[2][2], theme[2][3], alpha)
        screen.drawRectF(0, 0, 96, 32)

        if ticks > 20 then
            screen.setColor(255,255,255,lerp(0,255,(clamp(ticks-20,0,40))/40))
            drawLogo()
        end
    end
end

function c(...) local _={...}
    for i,v in pairs(_) do
     _[i]=_[i]^2.2/255^2.2*_[i]
    end
    screen.setColor(table.unpack(_))
end

function lerp(v0, v1, t)
    return v1 * t + v0 * (1 - t)
end

function clamp(v, min, max)
    return math.min(math.max(v, min), max)
end

function drawLogo()
    screen.drawRectF(52, 9, 2, 7)
    screen.drawRectF(42, 14, 4, 2)
    screen.drawRectF(42, 8, 1, 2)
    screen.drawRectF(47, 12, 1, 2)
    screen.drawRectF(46, 11, 1, 4)
    screen.drawRectF(45, 10, 1, 4)
    screen.drawRectF(43, 7, 2, 4)
    screen.drawRectF(44, 11, 1, 1)
    screen.drawRectF(45, 6, 11, 2)
    screen.drawRectF(44, 6, 1, 1)

    screen.drawTextBox(0, 14, 96, 16, car, 0, 0)
end

function drawGradient(tick)
    local width = 32
    local center = width / 2 - width
    for i = 0, width do
        local offset = tick * 1.2
        local r = lerp(theme[1][1], theme[2][1], i / width)
        local g = lerp(theme[1][2], theme[2][2], i / width)
        local b = lerp(theme[1][3], theme[2][3], i / width)
        c(r, g, b, clamp(tick * 5, 0, 255) * lerp(0.7, 1, 1 - ((width - i) / width)))
        screen.drawLine(center - i + offset, 0, center - i + offset, 32)
        screen.drawLine(center + i - width * 2 + offset, 0, center + i - width * 2 + offset, 32)
    end
end
