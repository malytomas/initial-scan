scan_queue_global = {}
scan_players_global = {}

function generate_queue(position)
  local res = {}
  local xx = position.x
  local yy = position.y
  for r = 300, 7, -1 do
    for y = -r, r, 1 do
      table.insert(res, {-r * 32 + xx, y * 32 + yy})
    end
    for x = -r, r, 1 do
      table.insert(res, {x * 32 + xx, r * 32 + yy})
    end
    for y = r, -r, -1 do
      table.insert(res, {r * 32 + xx, y * 32 + yy})
    end
    for x = r, -r, -1 do
      table.insert(res, {x * 32 + xx, -r * 32 + yy})
    end
  end
  return res
end

function initialize_scan(index, player)
  local scan = {}
  scan.force = player.force
  scan.surface = player.surface
  scan.queue = generate_queue(player.position)
  scan_queue_global[index] = scan
end

function perform_scan()
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

script.on_event(defines.events.on_player_created, function(event)
  scan_players_global[event.player_index] = game.players[event.player_index]
end)

script.on_event(defines.events.on_tick, function(event)
  if game.tick % 5 == 2 then
    for index, player in pairs(scan_players_global) do
      initialize_scan(index, player)
    end
    scan_players_global = {}
    perform_scan()
  end
end)

