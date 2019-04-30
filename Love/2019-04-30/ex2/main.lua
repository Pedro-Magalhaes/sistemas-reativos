local function newblip (slowDown)
  local x, y = 0, 0
  local width, height = love.graphics.getDimensions( )
  local myBlip
  local function wait(segundos, meublip)
      meublip.active = false
      meublip.activateTime = segundos
      coroutine.yield()
  end
  
  
  local move = coroutine.create( function ()
    while true do
      x = x+5
      if x > width then
        -- volta para a esquerda da janela
        x = 0
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
      love.graphics.rectangle("line", x, y, 10, 10)
    end,
    active = true,
    activateTime = 0
  }
  return myBlip
end

local function newplayer ()
  local x, y = 0, 200
  local width, height = love.graphics.getDimensions( )
  return {
  try = function ()
    return x
  end,
  update = function (dt)
    x = x + 0.5
    if x > width then
      x = 0
    end
  end,
  draw = function ()
    love.graphics.rectangle("line", x, y, 30, 10)
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
  end
end

function love.load()
  player =  newplayer()
  listabls = {}
  for i = 1, 5 do
    listabls[i] = newblip(i)
  end
end

function love.draw()
  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
end

function love.update(dt)
  player.update(dt)
  for i = 1,#listabls do
    listabls[i].update(dt)
  end
end
  
