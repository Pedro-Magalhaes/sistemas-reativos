--__debug__ = true

local function newloot ()
  local side = 25
  local x, y = math.random(width-side), math.random(height-side)
  local timer = 0
  local speed = 1
  local n_frames = 6
  local img = love.graphics.newImage("assets/coin_sprite.png")
  local img_width , img_height = img:getDimensions() 
  local sprite_width = img_width/n_frames
  local quads = {}
  for i=0, n_frames-1 do
    quads[i+1] = love.graphics.newQuad(i*sprite_width, 0, sprite_width, img_height, img_width, img_height)
  end
  
  local myLoot
  
  myLoot = {
    update = function(dt)
      timer = timer + dt*speed
    end,
    draw = function()
      love.graphics.draw(img, quads[(math.floor(timer)%n_frames) + 1], x, y, 0, side/sprite_width, side/img_height, sprite_width/2, img_height/2)
      if __debug__ then
        love.graphics.circle("line", x, y, side/2)
      end
    end,
    get_circ = function ()
      return {x=x, y=y, radius=side/2}
    end,
    }
    
    return myLoot
  end

local function newblip ()
  local vel = math.random(10, 100)
  local side = 25 + 30 * math.random()
  local dir = math.random(1, 4)
  local x_dir, y_dir, x, y
  if dir == 1 then
    x_dir, y_dir = 1, 0
    x, y = -side/2, side/2 + math.random(height-side/2)
  elseif dir == 2 then
    x_dir, y_dir = -1, 0
    x, y = width+side/2, side/2 + math.random(height-side/2)
  elseif dir == 3 then
    x_dir, y_dir = 0, 1
    x, y = side/2 + math.random(width-side/2), -side/2
  elseif dir == 4 then
    x_dir, y_dir = 0, -1
    x, y = side/2 + math.random(width-side/2), height+side/2
  end
  local myBlip
  local img = love.graphics.newImage("assets/asteroid.png")
  local img_width , img_height = img:getDimensions() 
  
  myBlip = {
    update = function (dt)
      x, y = x + vel*x_dir*dt, y + vel*y_dir*dt
    end,
    affected = function (pos)
      if pos>x and pos<x+10 then
      -- "pegou" o blip
        return true
      else
        return false
      end
    end,
    draw = function ()
      love.graphics.draw(img,x,y,0, side/img_width, side/img_height, img_width/2, img_height/2)
      if __debug__ then
        love.graphics.circle("line", x, y, side/2)
      end
    end,
    get_circ = function ()
      return {x=x, y=y, radius=side/2}
    end,
    out_of_screen = function ()
      return x > width or x < -side or y > height or y < -side
    end,
    active = true,
    activateTime = 0
  }
  return myBlip
end

local function newplayer ()
  local x, y = width/2, height/2
  local x_vel, y_vel = 0, 0
  local x_acc, y_acc = 0, 0
  local rec_width, rec_height = 50, 25
  local original_width, original_height = 50, 25
  local angle = 0
  local img = love.graphics.newImage("assets/enterprise.png")
  local img_width , img_height = img:getDimensions()
  local p = {}
  local c = {x=0, y=200}
  
  local function check_collision(circle)
    local function dist(x1,y1,x2,y2)
        return math.sqrt( (x2-x1)^2 + (y2-y1)^2 )
    end
    for _, point in ipairs(p) do
      if dist(point.x, point.y, circle.x, circle.y) < circle.radius then
        return true
      end
    end
    return false
  end
  
  return {
  update = function (dt)
    angle = math.atan2(y_vel,x_vel)
    rec_height = math.abs(math.cos(angle) * original_height) + math.abs(math.sin(angle) * original_width)
    rec_width = math.abs(math.cos(angle) * original_width) + math.abs(math.sin(angle) * original_height)
    x, y = x + x_vel, y + y_vel
    x_vel, y_vel = x_vel + x_acc, y_vel + y_acc
    c = {x = x + rec_width/2, y = y + rec_height/2}
    p[1] = {x = c.x - math.sin(angle) * original_height/2, y =  c.y + math.cos(angle) * original_height/2 }
    p[2] = {x = c.x + math.sin(angle) * original_height/2, y =  c.y - math.cos(angle) * original_height/2 }
    p[3] = {x = p[1].x + math.cos(angle) * original_width/2, y =  p[1].y + math.sin(angle) * original_width/2 }
    p[4] = {x = p[1].x - math.cos(angle) * original_width/2, y =  p[1].y - math.sin(angle) * original_width/2 }
    p[5] = {x = p[2].x + math.cos(angle) * original_width/2, y =  p[2].y + math.sin(angle) * original_width/2 }
    p[6] = {x = p[2].x - math.cos(angle) * original_width/2, y =  p[2].y - math.sin(angle) * original_width/2 }

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
    love.graphics.draw(img, c.x, c.y, angle, original_width/img_width, original_height/img_height, img_width/2, img_height/2)
    if __debug__ then
      love.graphics.print(string.sub(c.x, 1, 5) .. " " .. string.sub(c.y, 1, 5), 0,0)
      for _, point in ipairs(p) do
        love.graphics.circle("fill", point.x, point.y, 2)
      end
    end
  end,
  check_collision = check_collision
  }
end

function love.keypressed(key)
  if key == "down" then
    player.add_acc(0, 1)
  elseif key == "right" then
    player.add_acc(1, 0)
  elseif key == "left" then
    player.add_acc(-1, 0)
  elseif key == "up" then
    player.add_acc(0, -1)
  end
  if dead then
    love.load()
  end
end

function gen_score()
  return (os.time() - start) * 100 + 200*coins
end

function test_time (ostime, n_blips)
  return n_blips < math.floor(5 + (ostime-start)/5)
end

function love.keyreleased(key)
  if key == "down" or key == "up" then
    player.set_acc("y", 0)
  elseif key == "right" or key == "left" then
    player.set_acc("x", 0)
  end
end

function love.load()
  font = love.graphics.newImageFont("assets/font.png",
    " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"")
  love.graphics.setFont(font)
  dead = false
  width, height = love.graphics.getDimensions( )
  start = os.time()
  background = love.graphics.newImage("assets/espaco.jpg")
  player =  newplayer()
  loot = newloot()
  coins = 0
  listabls = {}
  math.randomseed(os.time())
  for i = 1, 5 do
    listabls[i] = newblip()
  end
end

local function death()
  death_score = score
  payer = nil
  dead = true
end

function love.draw()
  love.graphics.setColor(255,255,255,100)
  love.graphics.draw(background)
  love.graphics.setColor(255,255,255,255)
  if not dead then
    love.graphics.print("Score: " .. score, 0, height - 40, 0, 3, 3)
    loot.draw()
    player.draw()
    for i = 1, #listabls do
      listabls[i].draw()
    end
  else
    love.graphics.print("    Game Over\nFinal score: " .. death_score, 0, 200, 0, 5, 5)
  end
end

function love.update(dt)
  if not dead then
    score = gen_score()
    player.update(dt)
    for i = 1, #listabls do
      listabls[i].update(dt)
      loot.update(dt)
      if listabls[i].out_of_screen() then
        listabls[i] = newblip()
      elseif player.check_collision(listabls[i].get_circ()) then
        death()
      end
    end
    if test_time(os.time(), #listabls) then
      listabls[#listabls + 1] = newblip()
    end
    if player.check_collision(loot.get_circ()) then
      coins = coins + 1
      loot = newloot()
    end
  end
end
