local mqtt = require("mqtt_library")

local function newplayer(id,name)
  local playerid = id
  local playername = name
  local score = 0
  
  return {
      getid = function ()
        return playerid
      end,
      changescore = function (delta)
        score = score + delta
      end,
      getscore = function()
        return score
      end,
      draw = function(x,y)
      -- desenha id e score no local desejado  
      end,      
  }  
end


local function newgame ()
  local players = {}
  
  return {
  begin = function()
    print("begin")
  end,
  
  addPlayer = function(player)
    players[player.getid()]=player
  end,  
  update = function (dt)
    
  end,
  draw = function ()
    love.graphics.rectangle("line", x, y, 30, 10)
  end
  }
end

function mqttcb(topic, message)
   local id,btn = string.find(message,"([1-9]+)%s*,%s*([12])")
   print("mensagem recebida")
   print("id = "..id.." btn = "..btn)
end


function love.load()
  game =  newgame()
  listabls = {}
  mqtt_client = mqtt.client.create("85.119.83.194",   1883, mqttcb)
  print("antes de a")
  mqtt_client:connect("love")
  print("a")
  mqtt_client:subscribe({listen})
end

function love.draw()
  player.draw()
  --for i = 1,#listabls do
   -- listabls[i].draw()
 -- end
end

function love.update(dt)
  --player.update(dt)
  --for i = 1,#listabls do
  --  listabls[i].update(dt)
 -- end
end