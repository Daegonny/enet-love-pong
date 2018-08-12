enet = require "enet"
function love.load()
  host = enet.host_create()
  dest = nil
  server = host:connect("192.168.15.15:6789")
  feedback = ""
  idx = -1
  is_connected  = false

  right_limit = 800
  left_limit = 0
  top_limit = 0
  bottom_limit = 600

  player = {}
  player.w = 15
  player.h = 150
  player.x = left_limit + player.w/2
  player.y = bottom_limit/2
  player.score = 0
  player.can_draw = false

  enemy = {}
  enemy.w = 15
  enemy.h = 150
  enemy.x = left_limit + enemy.w/2
  enemy.y = bottom_limit/2
  player.score = 0
  enemy.can_draw = false

  ball = {}
  ball.w = 10
  ball.h = 10
  ball.x = player.x + player.w/2 + ball.w/2
  ball.y = bottom_limit/2
  ball.vx = .5
  ball.vy = .5
  ball.can_draw = false

  all_can_play = false
end

function listen_keyboard(dt)
  if love.keyboard.isDown("up") then
      --action, up, player, dt
      message = join({1, 0, idx, dt})
      dest:send(message)
      --feedback = message
  end
  if love.keyboard.isDown("down") then
      --action, up, player, dt
        message = join({1, 1, idx})
        dest:send(message)
        --feedback = message
    end
end

function listen_server(event)
  if event and event.type == "receive" then
    local message = event.data:split()
    feedback = event.data
    --position
    if message[1] == 3 then
      if message[3] == idx then
        player.y = message[2]
      else
        enemy.y = message[2]
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

function player_draw(p)
  if p.can_draw then
    love.graphics.rectangle("fill", (p.x - p.w/2), (p.y - p.h/2), p.w, p.h )
  end
end

function ball_draw(b)
  if b.can_draw then
    love.graphics.rectangle("fill", (b.x - b.w/2), (b.y - b.h/2), b.w, b.h)
  end
end

function request_idx(event)
  if event and event.type == "receive" then
    local message = event.data:split()
    --connect
    if message[1] == 0 and message[3] == 1 then
      idx = message[2]
      if idx == 1 then --player is left side and the other is not connected
        player.x = left_limit + player.w/2
        ball.x = player.x + player.w/2 + ball.w/2
      else --player is right side and all are connected
        player.x = right_limit - player.w/2
        enemy.x = left_limit + enemy.w/2
        ball.x = enemy.x + enemy.w/2 + ball.w/2
        enemy.can_draw = true
        all_can_play = true
        ball.can_draw = true
        ball.can_draw = true
      end
      player.can_draw = true
    end
  end
end

function request_enemy(event)
  if event and event.type == "receive" then
    local message = event.data:split()
    --connect
    if message[1] == 0 and message[3] == 1 then
      if message[2] == 2 then
        enemy.x = right_limit - enemy.w/2
        enemy.can_draw = true
        all_can_play = true
        ball.can_draw = true
      end
    end
  end
end

function connect(event)
  if event and event.type == "connect" then
    dest = event.peer
    message = event.peer:index() .. " conectou"
    is_connected = true
  end
end

function love.update(dt)
  local done = false
  if not done then

    local event = host:service(100)

    if not is_connected then
      connect(event)
    end

    if idx == -1 then
      request_idx(event)
    end

    if not all_can_play then
      request_enemy(event)
    end

    if all_can_play then
      listen_keyboard(dt)
      listen_server(event)
    end

  end
end

function love.draw()
  love.graphics.print("meu idx é ".. idx, 400, 300)
  love.graphics.print("feedback: ".. feedback, 400, 250)
  player_draw(player)
  player_draw(enemy)
  ball_draw(ball)
end
