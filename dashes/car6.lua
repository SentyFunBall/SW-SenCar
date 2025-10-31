-- Author: SentyFunBall
-- GitHub: https://github.com/SentyFunBall
-- Workshop: 

--Code by STCorp. Do not reuse.--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

-- Heavily abusing LifeBoatAPI's ability to paste code from other files
-- This literally gets pasted into dash.lua.

if (not usingSenconnect) and info.gear ~= 1 then
                --dont draw map or zoom btns if we're in reverse or if SC is connected (haha magic boolean)
                --screenX, screenY = map.screenToMap(info.gpsX, info.gpsY, 2, 96, 32, 58, 25)
                screen.drawMap(info.gpsX, info.gpsY, mapZoom)
                --map icon
                c(theme[3][1], theme[3][2], theme[3][3])
                drawPointer(48,16,info.compass, 5)
            end

            --side gradients
            c(theme[1][1], theme[1][2], theme[1][3], 250)
            screen.drawRectF(0, 22, 96, 10)
            for i=0, 28 do
                c(theme[1][1], theme[1][2], theme[1][3], easeLerp(250, 50, i/28))
                screen.drawLine(i, 0, i, 32)
                screen.drawLine(96-i, 0, 96-i, 32)
            end

            --- drive modes
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

            -- speed
            c(240, 240, 240)
            if info.properties.unit then
                local spd = math.floor(info.speed * 2.23694)
                dst(spd < 10 and 15 or spd < 100 and 11 or 7, 5, tostring(spd), 2)
                c(100, 100, 100)
                dst(13, 16, "MPH", 1)
            else 
                local spd = math.floor(info.speed * 3.6)
                dst(spd < 10 and 15 or spd < 100 and 11 or 7, 5, tostring(spd), 2)
                c(100, 100, 100)
                dst(13, 16, "KMH", 1)
            end

            -- gear
            c(200,200,200)
            if info.gear == 0 then
                dst(88,24,"P",1)
            elseif info.gear == 1 then
                dst(88,24,"R",1)
            elseif info.gear == 2 then
                dst(88,24,"N",1)
            elseif info.gear >= 3 then
                if info.properties.ev or info.properties.trans then
                    dst(info.properties.ev and 88 or 87, 24,"D",1)
                    if not info.properties.ev and info.properties.trans then
                        dst(94,24,string.format("%.0f", info.gear-2))
                    end
                else
                    dst(88,24,string.format("%.0f", info.gear-2),1)
                end
            end


            -- fuel and temp bars
            c(100, 100, 100)
            screen.drawRectF(13, 39, 11, 1)
            screen.drawRectF(72, 30, 11, 1)

            c(200, 200, 200)

            if info.properties.ev then
                -- battery icon
                screen.drawRect(15, 24, 5, 3)
                screen.drawRectF(21, 25, 1, 2)

                -- power usage icon
                screen.drawRectF(78, 25, 2, 2)
                screen.drawLine(78, 27, 76, 29)
                screen.drawRectF(76, 25, 2, 1)
                screen.drawRectF(77, 24, 2, 1)
                screen.drawRectF(78, 23, 2, 1)

                local battPerc = info.fuel / 1                         -- battery always 0-1
                c(240 - (battPerc * 120), 240, 240 - (battPerc * 120)) -- green full, red empty
                screen.drawRectF(13, 30, battPerc * 11, 1)

                -- gen power bar
                local genPerc = math.min(info.temp / 16, 1)            -- gen power production. 20 swatts/sec is probably max
                c(240, 240, 240)
                screen.drawRectF(72, 30, math.max(genPerc * 11 - 1, 0), 1)
                
            else
                info.fuel = clamp(info.fuel, 0, info.properties.maxfuel)
                local fuelPerc = info.fuel / info.properties.maxfuel
                c(240, 120 + (fuelPerc * 120), 120 + (fuelPerc * 120)) -- white full, red empty
                screen.drawRectF(13, 30, fuelPerc * 11, 1)

                info.temp = clamp(info.temp, 0, 120)                   -- engines dont usually go past 120C
                local tempPerc = math.min(info.temp / info.properties.tempwarn, 1)
                c(240, 240 - (tempPerc * 120), 240 - (tempPerc * 120)) -- white empty, red full
                screen.drawRectF(72, 30, tempPerc * 11, 1)
            end

            if not usingSenconnect and info.gear ~= 1 then
                --map zoom buttons
                c(200, 200, 200)
                screen.drawRectF(27, 24, 3, 1) --minus
                screen.drawRectF(67, 23, 1, 3) --plus
                screen.drawRectF(66, 24, 3, 1)
            end

            if useDimDisplay then
                screen.setColor(0, 0, 0, 150)
                screen.drawRectF(0, 0, 100, 32)
            end
