--startup
local s = false
local ticks = 0
local isEV = property.getBool("EV Mode (Do not change)")

-- This script was written for SenTOS Car 4, and I have no idea how it works. 
-- It doesn't sometimes, but it does most the time.
function onTick()
	local button = input.getBool(1)
	local cap = input.getBool(2)
	local shut = input.getBool(3)

    local dashTouch = input.getBool(4) and not pulse
	pulse = input.getBool(4)

	local seatOccupied = input.getBool(5)

	if cap then
		if button then
			if not s then
				s = true
			end
		else
			s = not s
		end
	end

	if isEV then
		if not seatOccupied then
			ticks = ticks + 1
			if ticks > 1800 then -- turn off after 30 seconds
				s = false
			end
		else
			ticks = 0
		end

		if not s and dashTouch then
			s = true
		end
	end

	if shut and s then s = false end
	output.setBool(1,s)
end