-- Author: SentyFunBall
-- GitHub: https://github.com/SentyFunBall
-- Workshop: 

--Code by STCorp. Do not reuse.--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

            -- only draw speed in reverse
            if info.gear == 1 then
                c(240, 240, 240)
                if info.properties.unit then
                    local spd = math.floor(info.speed * 2.23694)
                    dst(6, 4, tostring(spd), 2)
                    c(200, 200, 200)
                else
                    dst(6, 4, tostring(info.speed * 3.6), 2)
                    c(200, 200, 200)
                end
                return
            end

            local function gradientLine(x1, y1, x2, y2, colorS, colorE, progress, steps)
                progress = progress or 1
                steps = steps or math.max(math.abs(x2 - x1), math.abs(y2 - y1))
                for i = 0, steps do
                    local t = i / steps
                    if t > progress then break end
                    c(
                        easeLerp(colorS[1], colorE[1], t),
                        easeLerp(colorS[2], colorE[2], t),
                        easeLerp(colorS[3], colorE[3], t)
                    )
                    screen.drawLine(
                        math.floor(easeLerp(x1, x2, t)),
                        math.floor(easeLerp(y1, y2, t)),
                        math.floor(easeLerp(x1, x2, (i + 1) / steps)),
                        math.floor(easeLerp(y1, y2, (i + 1) / steps))
                    )
                end
            end

            -- background gradient, breaths in and out sorta kinda
            c(
                easeLerp(theme[1][1] * 2, theme[2][1], ticks / 720),
                easeLerp(theme[1][2] * 2, theme[2][2], ticks / 720),
                easeLerp(theme[1][3] * 2, theme[2][3], ticks / 720),
                210
            )
            screen.drawRectF(0, 0, 96, 32)

            -- bars
            local speedColors = {
                { 1, 207, 239 },
                { 87, 0, 94 }
            }
            gradientLine(6, 16, 41, 16, speedColors[1], speedColors[2])
            c(20, 20, 20, 220)
            screen.drawRectF(6, 16, 35, 1)
            local speedProgress = clamp(info.speed / info.properties.topspeed, 0, 1)
            gradientLine(6, 16, 41, 16, speedColors[1], speedColors[2], speedProgress, 35)

            local rpsColors = {
                { 255, 209, 102 },
                { 94, 53, 1 }
            }
            gradientLine(55, 16, 90, 16, rpsColors[1], rpsColors[2])
            c(20, 20, 20, 220)
            screen.drawRectF(55, 16, 35, 1)
            if info.properties.ev then
                gradientLine(55, 16, 90, 16, rpsColors[1], rpsColors[2], info.rps, 35)
            else
                local rpsProgress = clamp(info.rps / info.properties.upshift, 0, 1)
                gradientLine(55, 16, 90, 16, rpsColors[1], rpsColors[2], rpsProgress, 35)
            end

            c(0, 187, 62)
            screen.drawLine(6, 28, 41, 28)
            c(20, 20, 20, 220)
            screen.drawRectF(6, 28, 35, 1)

            -- compass lines
            -- this is to create a moving effect on the compass bar when turning
            c(0, 187, 62)
            for i = 0, 32, 2 do
                screen.drawRectF(56 + i - compIndicatorOffset, 28, 1, 1)
            end


            -- speed
            c(240, 240, 240)
            if info.properties.unit then
                local spd = math.floor(info.speed * 2.23694)
                dst(6, 4, tostring(spd), 2)
                c(200, 200, 200)
                dst(30, 9, "MPH", 1)
            else 
                local spd = math.floor(info.speed * 3.6)
                dst(6, 4, tostring(spd), 2)
                c(200, 200, 200)
                dst(30, 9, "KMH", 1)
            end

            -- gear
            if info.gear == 0 then
                dst(56, 9, "P")
            elseif info.gear == 1 then
                dst(56, 9, "R")
            elseif info.gear == 2 then
                dst(56, 9, "N")
            elseif info.gear >= 3 then
                if info.properties.ev or info.properties.trans then
                    dst(info.properties.ev and 56 or 55, 9, "D")
                    if not info.properties.ev and info.properties.trans then
                        dst(56, 13, string.format("%.0f", info.gear - 2))
                    end
                else
                    dst(56, 9, string.format("%.0f", info.gear - 2))
                end
            end
            
            if info.properties.ev then
                -- battery
                screen.drawRect(7, 22, 5, 3)
                screen.drawRectF(13, 23, 1, 2)

                local batteryPercent = info.fuel / 1
                c(
                    lerp(187, 0, batteryPercent),
                    lerp(0, 187, batteryPercent),
                    lerp(0, 62, batteryPercent)
                )
                screen.drawRectF(6, 28, (info.fuel / 1) * 35, 1)
                c(240, 240, 240)
                dst(25, 22, string.format("%.0f%%", batteryPercent * 100))
            else
                --- fuel
                if info.fuel / info.properties.maxfuel < info.properties.fuelwarn then
                    c(150, 50, 50)
                end
                screen.drawRectF(1,29,3,2)
                screen.drawRect(1,26,2,2)
                screen.drawLine(5,27,5,31)
                screen.drawRectF(4,29,1,1)
                screen.drawRectF(4,26,1,1)

                c(0, 187, 62)
                screen.drawRectF(6, 28, (info.fuel / info.properties.maxfuel) * 35, 1)
            end

            -- compass heading
            c(240, 240, 240)
            local x = deg < 10 and 67 or deg < 100 and 65 or 62
            dst(x, 22, degStr)
            screen.drawRect(x + #degStr * 4, 22, 2, 2)
            local dirStr = deg >= 337.5 and "N" or deg < 22.5 and "N" or deg >= 22.5 and deg < 67.5 and "NE" or
                deg >= 67.5 and deg < 112.5 and "E" or deg >= 112.5 and deg < 157.5 and "SE" or
                deg >= 157.5 and deg < 202.5 and "S" or deg >= 202.5 and deg < 247.5 and "SW" or
                deg >= 247.5 and deg < 292.5 and "W" or "NW"
            dst(x + #degStr * 4 + 4, 22, dirStr)

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