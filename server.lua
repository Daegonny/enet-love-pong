require "enet"
host = enet.host_create("0.0.0.0:6789", 2)
message = ""
peers = {}

players = {}

right_limit = 800
left_limit = 0
top_limit = 0
bottom_limit = 600

players[1] = {}
players[1].w = 15
players[1].h = 150
players[1].x = left_limit + players[1].w/2
players[1].y = bottom_limit/2
players[1].old_y = bottom_limit/2
players[1].v = 4.5
players[1].score = 0

players[2] = {}
players[2].w = 15
players[2].h = 150
players[2].x  = right_limit - players[2].w/2
players[2].y = bottom_limit/2
players[2].old_y = bottom_limit/2
players[2].v = 4.5
players[2].score = 0

ball = {}
ball.w = 10
ball.h = 10
ball.x = players[1].x + players[1].w/2 + ball.w/2
ball.y = players[1].y
ball.vx = .5
ball.vy = .5
ball.lambda = 1


function test_n_solve_colision()
  for k, p in ipairs(players) do



  end
end

function is_colliding(obj1, obj2)
--	if (obj1.x + obj1.w)
end


function listen(event)
  if event and event.type == "receive" then
    local message = event.data:split()
    -- print(event.data)
    --action
    if message[1] == 1 then
      local idx = message[3]
      local dt = message[4]
      --move up
      if message[2] == 0 then
        players[idx].old_y = players[idx].y
        players[idx].y = players[idx].y - (players[idx].v)
        local m = join({3, players[idx].y, idx})
        host:broadcast(m)

      --move down
      elseif message[2] == 1 then
        players[idx].old_y = players[idx].y
        players[idx].y = players[idx].y + (players[idx].v)
        local m = join({3, players[idx].y, idx})
        host:broadcast(m)
      end


    end

  end
end

function join(t)
  return table.concat(t, ";")
end

function string:split(sep)
   local sep, fields = sep or ";", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = tonumber(c) end)
   return fields
end

function add_player(peer)
  table.insert(peers, peer)
end

function handle_connection(event)
  if event and event.type == "connect" then
    print(event.peer)
    print(event.peer:index())

    add_player(event.peer)

    --connection, player peer:index(), connected
    event.peer:send(join({0, event.peer:index(), 1}))

    --send enemy
    if event.peer:index() > 1 then
      host:get_peer(1):send(join({0, 2, 1}))
    end
  end
end

print("server is up!")

while true do
  local event = host:service(100)
  handle_connection(event)
  listen(event)
end
