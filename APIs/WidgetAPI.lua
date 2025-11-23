-- Author: SentyFunBall
-- GitHub: https://github.com/SentyFunBall
-- Workshop: 

--Code by STCorp. Do not reuse.--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require("LifeBoatAPI")

active= {slot1 = {id = -1, large = false}, slot2 = {id = -1, large = false}, slot3 = {id = -1, large = false}}


WidgetAPI = {
    draw = function (slot, large, widget, color)
        widget.drawn = false --by default, we assume it didnt draw
        color = color or {100, 100, 100}
        c(color[1], color[2], color[3], 200)
        if slot == 1 then
            if active.slot1.id == widget.id then --if the widget is assigned to this slot
                if large then --large widget, draw the large style
                    drawRoundedRect((slot-1)*32+2, 2, 58, 27)
                    for i = 1, #widget do
                        if widget[i].color then
                            c(widget[i].color[1], widget[i].color[2], widget[i].color[3])
                        else
                            c(color[1]+20, color[2]+20, color[3]+20)
                        end
                        if widget[i].h then
                            screen.drawText((slot-1)*32+33+widget[i].x, widget[i].y+3, widget[i].content)
                        else
                            screen.drawText((slot-1)*32+3+widget[i].x, widget[i].y+3, widget[i].content)
                        end
                    end
                    widget.drawn = true
                else --dont draw the large style
                    drawRoundedRect((slot-1)*32+2, 2, 27, 27)
                    for i = 1, #widget do
                        if widget[i].color then
                            c(widget[i].color[1], widget[i].color[2], widget[i].color[3])
                        else
                            c(color[1]+20, color[2]+20, color[3]+20)
                        end
                        screen.drawText((slot-1)*32+3+widget[i].x, widget[i].y+3, widget[i].content)
                    end
                    widget.drawn = true
                end
            else
                if active.slot1.id == -1 then
                    if large then
                        active.slot1.id = widget.id
                        active.slot1.large = true
                        active.slot2.id = widget.id
                    else
                        active.slot1.id = widget.id
                        active.slot1.large = false
                    end
                else
                    widget.drawn = false
                end
            end
        elseif slot == 2 then
            if active.slot2.id == widget.id and not active.slot1.large then
                if large then --large widget, draw the large style
                    drawRoundedRect((slot-1)*32+2, 2, 58, 27)
                    for i = 1, #widget do
                        if widget[i].color then
                            c(widget[i].color[1], widget[i].color[2], widget[i].color[3])
                        else
                            c(color[1]+20, color[2]+20, color[3]+20)
                        end
                        if widget[i].h then
                            screen.drawText((slot-1)*32+33+widget[i].x, widget[i].y+3, widget[i].content)
                        else
                            screen.drawText((slot-1)*32+3+widget[i].x, widget[i].y+3, widget[i].content)
                        end
                    end
                    widget.drawn = true
                else --dont draw the large style
                    drawRoundedRect((slot-1)*32+2, 2, 27, 27)
                    for i = 1, #widget do
                        if widget[i].color then
                            c(widget[i].color[1], widget[i].color[2], widget[i].color[3])
                        else
                            c(color[1]+20, color[2]+20, color[3]+20)
                        end
                        screen.drawText((slot-1)*32+3+widget[i].x, widget[i].y+3, widget[i].content)
                    end
                    widget.drawn = true
                end
            else
                if active.slot2.id == -1 then
                    if large then
                        active.slot2.id = widget.id
                        active.slot2.large = true
                        active.slot3.id = widget.id
                    else
                        active.slot2.id = widget.id
                        active.slot2.large = false
                    end
                else
                    widget.drawn = false
                end
            end
        elseif slot == 3 then
            if active.slot3.id == widget.id and not active.slot2.large then
                if large then
                    drawRoundedRect((slot-1)*32+2, 2, 27, 27)
                    screen.setColor(255,255,255)
                    screen.drawRectF(76,13,1,1)
                    screen.drawRectF(76,18,1,1)
                    screen.drawRectF(83,13,1,1)
                    screen.drawRectF(83,18,1,1)
                    screen.drawLine(82,14,82,17)
                    screen.drawText(73, 21, "err")
                else --THERE IS NO LARGE THERE IS NO LARGE THERE IS NO LARGE
                    drawRoundedRect((slot-1)*32+2, 2, 27, 27)
                    for i = 1, #widget do
                        if widget[i].color then
                            c(widget[i].color[1], widget[i].color[2], widget[i].color[3])
                        else
                            c(color[1]+20, color[2]+20, color[3]+20)
                        end
                        screen.drawText((slot-1)*32+3+widget[i].x, widget[i].y+3, widget[i].content)
                    end
                    widget.drawn = true
                end
            else
                if active.slot3.id == -1 then
                    if large then
                        active.slot3.id = widget.id
                        widget.drawn = true
                        return widget
                    else
                        active.slot3.id = widget.id
                        active.slot3.large = false
                    end
                else
                    widget.drawn = false
                end
            end
        end
        return widget
    end,

    remove = function (slot, id)
        local didRemove = false
        if slot == 1 then
            if id == active.slot1.id then
                active.slot1.id = -1
                didRemove = true
            end
        elseif slot == 2 then
            if id == active.slot2.id then
                active.slot2.id = -1
                didRemove = true
            end
        elseif slot == 3 then
            if id == active.slot2.id then
                active.slot2.id = -1
                didRemove = true
            end
        end
        return didRemove
    end
}

function drawRoundedRect(x, y, w, h)
    screen.drawRectF(x+1, y+1, w-1, h-1) --body
    screen.drawLine(x+2, y, x+w-1, y) --top
    screen.drawLine(x, y+2, x, y+h-1) --left
    screen.drawLine(x+w, y+2, x+w, y+h-1) --right
    screen.drawLine(x+2, y+h, x+w-1, y+h) --bottom
end
