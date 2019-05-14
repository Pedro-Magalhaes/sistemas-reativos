local function newblip (slowDown)
  local width, height = love.graphics.getDimensions( )
  local x_dir, y_dir = -1, 0
  local scale = math.random()
  print(scale)
  local rec_width, rec_height = 15 + 30 * scale, 15 + 30 * scale
  local x, y = width, math.random(height)
  local myBlip
  local img = love.graphics.newImage("assets/asteroid.png")
  local img_width , img_height = img:getDimensions() 
  local function wait(segundos, meublip)
      meublip.active = false
      meublip.activateTime = segundos
      coroutine.yield()
  end
  
  local move = coroutine.create( function ()
    while true do
      x, y = x + 5*x_dir, y + 5*y_dir
      if x < 0 then
        -- volta para a esquerda da janela
        x = width
      end
      wait(0.1*slowDown +0.1,myBlip)
    end
  end)
  
  local function movementCheck(dt)
    if myBlip.active then
      coroutine.resume(move)
    else
      myBlip.activateTime = myBlip.activateTime - dt
      if myBlip.activateTime <= 0 then
        myBlip.activateTime = 0
        myBlip.active = true
      end      
    end   
  end
  myBlip = {
    update = movementCheck,
    affected = function (pos)
      if pos>x and pos<x+10 then
      -- "pegou" o blip
        return true
      else
        return false
      end
    end,
    draw = function ()
      love.graphics.draw(img,x,y,0, rec_width/img_width, rec_height/img_height)
--      love.graphics.rectangle("line", x, y, rec_width, rec_height)
    end,
    get_rect = function ()
      return {x=x, y=y, width=rec_width, height=rec_height}
    end,
    active = true,
    activateTime = 0
  }
  return myBlip
end

local function newplayer ()
  local x, y = 0, 200
  local x_vel, y_vel = 0, 0
  local x_acc, y_acc = 0, 0
  local width, height = love.graphics.getDimensions( )
  local rec_width, rec_height = 50, 25
  local original_width, original_height = 50, 25
  local angle = 0
  local img = love.graphics.newImage("assets/enterprise.png")
  local img_width , img_height = img:getDimensions()
  
  local function check_collision(blip)
        local function dist(x1,y1,x2,y2)
            return math.sqrt( (x2-x1)^2 + (y2-y1)^2 )
        end
        local p1 = {x = x - math.sin(angle) * original_height/2, y =  y - math.cos(angle) * original_height/2 }
        local p2 = {x = x + math.sin(angle) * original_height/2, y =  y + math.cos(angle) * original_height/2 }
        
  end
  
  
  return {
  try = function ()
    return {x=x,y=y}
  end,
  update = function (dt)
    angle = math.atan2(y_vel,x_vel)
    rec_height = math.abs(math.cos(angle) * original_height) + math.abs(math.sin(angle) * original_width)
    rec_width = math.abs(math.cos(angle) * original_width) + math.abs(math.sin(angle) * original_height)
    x, y = x + x_vel, y + y_vel
    x_vel, y_vel = x_vel + x_acc, y_vel + y_acc
    if x > width then
      x = -rec_width
    elseif x < -rec_width then
      x = width
    end
    if y > height then
      y = -rec_height
    elseif y < -rec_height then
      y = height
    end
    x_vel = x_vel - 0.1*x_vel
    y_vel = y_vel - 0.1*y_vel
  end,
  add_speed = function (dx, dy)
    x_vel, y_vel = x_vel + dx, y_vel + dy
  end,
  add_acc = function (dx, dy)
    x_acc, y_acc = x_acc + dx, y_acc + dy
  end,
  set_acc = function (axis, val)
    if axis == "x" then
      x_acc = val
    else
      y_acc = val
    end
  end,
  draw = function ()
    love.graphics.draw(img,x + rec_width/2 ,y + rec_height/2 ,angle, original_width/img_width, original_height/img_height, img_width/2, img_height/2)
    love.graphics.rectangle("line", x, y, rec_width, rec_height)
  end,
  check_collision = function (blip)
    return x < blip.x + blip.width and
         blip.x < x+rec_width and
         y < blip.y+blip.height and
         blip.y < y+rec_height
  end
  }
end

function love.keypressed(key)
  if key == 'a' then
    pos = player.try()
    for i in ipairs(listabls) do
      local hit = listabls[i].affected(pos)
      if hit then
        table.remove(listabls, i) -- esse blip "morre" 
        return -- assumo que apenas um blip morre
      end
    end
  elseif key == "down" then
    player.add_acc(0, 1)
  elseif key == "right" then
    player.add_acc(1, 0)
  elseif key == "left" then
    player.add_acc(-1, 0)
  elseif key == "up" then
    player.add_acc(0, -1)
  end
end

function love.keyreleased(key)
  if key == "down" or key == "up" then
    player.set_acc("y", 0)
  elseif key == "right" or key == "left" then
    player.set_acc("x", 0)
  end
end

function love.load()
  background = love.graphics.newImage("assets/espaco.jpg")
  player =  newplayer()
  listabls = {}
  math.randomseed(os.time())
  for i = 1, 5 do
    listabls[i] = newblip(i)
  end
end

function love.draw()
  love.graphics.setColor(255,255,255,100)
  love.graphics.draw(background)
  love.graphics.setColor(255,255,255,255)
  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
end

function love.update(dt)
  player.update(dt)
  for i = 1,#listabls do
    listabls[i].update(dt)
    if player.check_collision(listabls[i].get_rect()) then
      player = newplayer()
    end
  end
end
  
