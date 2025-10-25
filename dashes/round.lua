-- Author: SentyFunBall
-- GitHub: https://github.com/SentyFunBall
-- Workshop: 

--Code by STCorp. Do not reuse.--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


            -- background gradient
            -- different from the others, this is a constant background that "breaths" over time

            c(
                easeLerp(theme[1][1] * 2, theme[2][1], ticks / 720),
                easeLerp(theme[1][2] * 2, theme[2][2], ticks / 720),
                easeLerp(theme[1][3] * 2, theme[2][3], ticks / 720),
                210
            )
            screen.drawRectF(0, 0, 96, 32)

            local dialStart = -90/2*oneDeg --bunch of like cool math stuff
            local dialEnd = 270*oneDeg

            -- circles
            c(theme[1][1] + 15, theme[1][2] + 15, theme[1][3] + 15)
            drawCircle(48, 13, 12, 9, 24, 0, pi2) -- speed
            drawCircle(78, 11, 10, 8, 16, 0, pi2) -- tach (power for evs)
            drawCircle(31, 26, 7, 6, 8, dialStart, dialEnd) -- fuel
            
            c(200, 200, 200)
            if info.properties.unit then
                dst(42, 13, "mph")
                local spd = math.floor(info.speed * 2.23694)
                dst(spd < 10 and 46 or spd < 100 and 44 or 42, 6, tostring(spd))
            else
                dst(42, 26, "km/h")
                local spd = math.floor(info.speed * 3.6)
                dst(spd < 10 and 46 or spd < 100 and 44 or 42, 19, tostring(spd))
            end
            dst(info.properties.ev and 74 or 72, 11, info.properties.ev and "kW" or "RPS")
            
            --clock hands
            local clockHour = math.floor(lastClock * 24) % 12 / 12 * pi2
            local clockMin = math.floor((lastClock * 1440) % 60) / 60 * pi2
            clockHour = clockHour + (clockMin - clockHour) / 12 -- smooth hour hand
            screen.drawLine(65, 25, 65 + math.sin(clockHour) * 5, 25 - math.cos(clockHour) * 5, 2)
            screen.drawLine(65, 25, 65 + math.sin(clockMin) * 5, 25 - math.cos(clockMin) * 5, 2)
            
            if info.gear == 0 then
                dst(76,5,"P")
            elseif info.gear == 1 then
                dst(76,5,"R")
            elseif info.gear == 2 then
                dst(76,5,"N")
            elseif info.gear >= 3 then
                if info.properties.ev or info.properties.trans then
                    dst(info.properties.ev and 76 or 74, 5,"D")
                    if not info.properties.ev and info.properties.trans then
                        dst(78,5,string.format("%.0f", info.gear-2))
                    end
                else
                    dst(76,5,string.format("%.0f", info.gear-2))
                end
            end
            
            -- icons
            if info.properties.ev then
                --battery
                screen.drawRect(27, 24, 5, 3)
                screen.drawRectF(33, 25, 1, 2)
            else
                -- fuel
                screen.drawRectF(28,26,3,2)
                screen.drawRect(28,23,2,2)
                screen.drawLine(32,24,32,28)
                screen.drawRectF(31,26,1,1)
                screen.drawRectF(31,23,1,1)
            end
            
            --- drive modes
            c(theme[3][1], theme[3][2], theme[3][3])
            if info.drivemode == 1 then --eco
                dst(42,26,"Eco")
            elseif info.drivemode == 2 then --sport
                dst(38,26,"Sport")
            elseif info.drivemode == 3 then --tow
                dst(42,26,"Tow")
            elseif info.drivemode == 4 then --dac
                dst(42,26,"DAC")
            end
            
            -- dials that fill up
            c(theme[2][1], theme[2][2], theme[2][3])
            drawCircle(19, 11, 10, 8, 16, 0, pi2) -- compass
            drawCircle(65, 25, 7, 6, 8, 0, pi2) -- clock
            drawCircle(48, 13, 12, 9, 60, dialStart, math.min(info.speed / 100 / info.properties.topspeed, 1) * dialEnd) -- speed
            
            if info.properties.ev then
                drawCircle(78, 11, 10, 8, 32, dialStart, math.min(info.rps / 20, 1) * dialEnd) -- power
                drawCircle(31, 26, 7, 6, 16, dialStart, math.min(info.fuel / 1, 1) * dialEnd) -- battery
            else
                drawCircle(78, 11, 10, 8, 32, dialStart, math.min(info.rps / 20, 1) * dialEnd) -- tach
                drawCircle(31, 26, 7, 6, 16, dialStart, math.min(info.fuel / info.properties.maxfuel, 1) * dialEnd) -- fuel
            end
            
            c(theme[2][1], theme[2][2], theme[2][3])
            drawPointer(18, 10, info.compass, 5) -- compass pointer