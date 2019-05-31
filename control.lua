scan_queue_global = {}

function generate_queue(position)
  local res = {}
  local xx = position.x / 32
  local yy = position.y / 32
  for r = 300, 7, -1 do
    for x = r, -r, -1 do
      table.insert(res, {(x + xx) * 32, -r * 32})
      table.insert(res, {(x + xx) * 32,  r * 32})
    end
    for y = r, -r, -1 do
      table.insert(res, {-r * 32, (y + yy) * 32})
      table.insert(res, { r * 32, (y + yy) * 32})
    end
  end
  return res
end

script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  local scan = {}
  scan.force = player.force
  scan.surface = player.surface
  scan.queue = generate_queue(player.position)
  scan_queue_global[event.player_index] = scan
end)

script.on_event(defines.events.on_tick, function(event)
  if game.tick % 5 == 2 then
    for index, scan in pairs(scan_queue_global) do
      if #scan.queue == 0 then
        local player = game.players[index]
        if player ~= nil then
          player.print("Initial map scan done")
        end
        table.remove(scan_queue_global, index)
      else
        local h = scan.queue[#scan.queue]
        table.remove(scan.queue)
        scan.force.chart(scan.surface, {h, h})
      end
    end
  end
end)

