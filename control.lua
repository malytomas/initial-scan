
if not global.scan then
	global.scan = {}
end

function scan_offset(step)
	local mx = settings.global["initial-scan-radius"].value
	local r = 7
	local a = 0
	while r < mx do
		local b = a + r * 8
		if b >= step then
			local c = step - a
			local s = math.floor(c / (r * 2))
			c = c - s * r * 2
			if s == 0 then
				return { c - r, r }
			end
			if s == 1 then
				return { r, r - c }
			end
			if s == 2 then
				return { r - c, -r }
			end
			if s == 3 then
				return { -r, c - r }
			end
		end
		a = b
		r = r + 1
	end
	return nil
end

function perform_scan(index, data)
	local player = game.players[index]
	local off = scan_offset(data.step)
	if not off or not player then
		global.scan[index] = nil
		return
	end
	local pos = {
		data.pos[1] + off[1] * 32,
		data.pos[2] + off[2] * 32,
	}
	player.force.chart(player.surface, { pos, pos })
	global.scan[index].step = data.step + 1
end

script.on_event(defines.events.on_player_created, function(event)
	local data = {}
	data.step = 0
	local player = game.players[event.player_index]
	data.pos = { player.position.x, player.position.y }
	global.scan[event.player_index] = data
end)

script.on_event(defines.events.on_tick, function(event)
	if (game.tick + 42) % settings.global["initial-scan-period"].value == 0 then
		for index, data in pairs(global.scan) do
			perform_scan(index, data)
		end
	end
end)

