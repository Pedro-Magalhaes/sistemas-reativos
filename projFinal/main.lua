local mqtt = require("mqtt_library")
local questions = require("gameconfig")
local controle = true
local listen = "mcu"
local publish = "love"
local broadcast = "0"

local curr_message = nil
local tratamento
local n_players = 0
local n_question = 0

local state = "cadastro"
--[[ states:
  cadastro: aguardando players recebe mensagens com o id dos mcus envia ack respondendo ao cadastro
  fase: recebe mensagens na forma <idMcu,btn>
  endgame: nao recebe mensagens
  
]]

local function newplayer(id,name)
  local playerid = id
  local playername = name
  local score = 0
  local curr_answer
  
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
    getname = function()
      return playername
    end, 
    saveanswer = function(btn)
      curr_answer = btn
    end,
    getanswer = function()
      return curr_answer 
    end
      
  }  
end

function tratamento_nulo(id, btn)
  return
end

function tratamento_cad(id, btn)
  print("cad id = " .. id .. " btn = " .. btn)
  if not players[id] then
    n_players = n_players + 1
    players[id]=newplayer(id, n_players)
  end
  
end

function tratamento_fase(id, btn)
  print("fase id = " .. id .. " btn = " .. btn)
  players[id].saveanswer(btn)  
  
end

function checkanswer()
    for _, player in pairs(players) do
      local a = player.getanswer()
      print("respostas",a , questions[n_question].a, a == questions[n_question].a)
        if a then
            if a == questions[n_question].a then
              print("acertou")
              player.changescore(100)
            else
              print("errou")
              player.changescore(-100)
            end
            return
        end
        print("sem resposta")
      end
end

local function endgame()
  local highScore = -100000
  local winner = -10000
  for playerid, player in pairs(players) do
    local score = player.getscore()
    if score > highScore then
      winner = playerid
    end
  end
  mqtt_client:publish(publish,broadcast .. "," .. winner) -- postando o vencedor
end


function newQuestion() 
  n_question = n_question + 1
  if n_question > #questions then
    state = "fim"
    endgame()
    return
  end
  for _, player in pairs(players) do
      player.saveanswer(nil)
  end
  
end

function mqttcb(topic, message)
   -- as msgs recebidas sao no padrao <id,btn>, btn é 1 ou 2, id é um int
   local id,btn = message:match("([1-9]+)%s*,%s*([12])") 
   controle = not controle -- TODO: retirar??
   print("mensagem recebida " .. message)
   print("id = " .. id .. " btn = " .. btn)
   tratamento(id, tonumber(btn))
end


function love.load()
  players = {}
  n_players = 0
  n_question = 0
  state = "cadastro"
  tratamento = tratamento_cad
  
  listabls = {}
  mqtt_client = mqtt.client.create("test.mosquitto.org",   1883, mqttcb)
  mqtt_client:connect("love1611")
  mqtt_client:subscribe({listen})
end

function love.keypressed(key)
  if state == "cadastro" then 
      if key == "return" then
        state = "fase"
        tratamento = tratamento_fase
        newQuestion()
      end
  
  elseif state == "fase" then 
      if key == "return" then
        checkanswer()
        newQuestion()
      end
  end  
end


function love.draw()
  
    if state == "cadastro" then
      love.graphics.print('Cadastre jogadores', 250, 250)
      for _, player in pairs(players) do
        love.graphics.print( 'Player ' .. player.getname() .. ', ID: ' .. player.getid(), 250, 250 + 20 * player.getname())
      end
    end
    
    if state == "fase" then
        love.graphics.print(questions[n_question].q, 250, 250)
        for _, player in pairs(players) do
        love.graphics.print( 'Player ' .. player.getname() .. ', score: ' .. player.getscore(), 250, 250 + 20 * player.getname())
      end
    end
    
end

function love.update(dt)
  mqtt_client:handler()    
end