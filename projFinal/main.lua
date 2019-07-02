local mqtt = require("mqtt_library")
local questions = require("gameconfig")
local listen = "mcu"
local publish = "love"
local broadcast = "0"

local curr_message = nil
local tratamento
local n_players = 0
local n_question = 0
local highScore = -100000
local state = "cadastro"
local width, height
local back_width , back_height
--[[ states:
  cadastro: aguardando players recebe mensagens com o id dos mcus envia ack respondendo ao cadastro
  fase: recebe mensagens na forma <idMcu,btn>
  endgame: nao recebe mensagens
  
]]

local gameWinner

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
  if players[id] ~= nil then
    if players[id].getanswer() == nil then
      players[id].saveanswer(btn)
      print("fase id = " .. id .. " btn = " .. btn, "player "..players[id].getname())   
      mqtt_client:publish(publish,id .. "," .. "ack")
    end
  end
end

function checkanswer()
    for i, player in pairs(players) do
      local a = player.getanswer()
      print("respostas", "player " .. i, " "..player.getname() ,a , questions[n_question].a, a == questions[n_question].a)
        if a then
            if a == questions[n_question].a then
              print("acertou")
              player.changescore(100)
            else
              print("errou")
              player.changescore(-100)
            end
        
        else
          print("sem resposta")
        end
        
      end
end

local function endgame()
  highScore = -100000
  local winner = -10000
  for playerid, player in pairs(players) do
    local score = player.getscore()
    if score > highScore then
      winner = playerid
      highScore = score
    end
  end
  for playerid, player in pairs(players) do
    if player.getscore() == highScore then 
      mqtt_client:publish(publish,playerid .. "," .. "vitoria")
    else
      mqtt_client:publish(publish,playerid .. "," .. "derrota")
    end
  end
  gameWinner = winner
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
  mqtt_client:publish(publish,broadcast .. "," .. "responder")
  
end

function mqttcb(topic, message)
   -- as msgs recebidas sao no padrao <id,btn>, btn é 1 ou 2, id é um int
   print("mensagem recebida " .. message)
   local id,btn = message:match("([0-9]+)%s*,%s*([12])") 
   print("id = " .. id .. " btn = " .. btn)
   tratamento(id, tonumber(btn))
end


function love.load()
  players = {}
  n_players = 0
  n_question = 0
  state = "cadastro"
  tratamento = tratamento_cad
  font = love.graphics.newImageFont("assets/font.png",
    " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"")
  love.graphics.setFont(font)
  width, height = love.graphics.getDimensions( )
  background = love.graphics.newImage("assets/wood.jpg")
  back_width , back_height = background:getDimensions()
  
  mqtt_client = mqtt.client.create("85.119.83.194",   1883, mqttcb)
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

  love.graphics.draw(background, width/2, height/2, 0, width/back_width, height/back_height, back_width/2, back_height/2)
  
  if state == "cadastro" then
    love.graphics.print('Cadastre jogadores', 250, 250, 0, 2, 2)
    for _, player in pairs(players) do
      love.graphics.print( 'Player ' .. player.getname() .. '\nscore: ' .. player.getscore(), -300 + 400 * player.getname(), 400, 0, 2, 2)
    end
  elseif state == "fase" then
    love.graphics.print(questions[n_question].q, 50, 250, 0, 2, 2)
    for _, player in pairs(players) do
      if player.getanswer() == nil then
        love.graphics.setColor(255, 0, 0)
      else
        love.graphics.setColor(0, 255, 0)
      end
      love.graphics.print( 'Player ' .. player.getname() .. '\nscore: ' .. player.getscore(), -300 + 400 * player.getname(), 400, 0, 2, 2)
      love.graphics.setColor(255, 255, 255)
    end
  elseif state == "fim" then
    for _, player in pairs(players) do
      if player.getscore() == highScore then
        love.graphics.setColor(0, 255, 0)
        love.graphics.print( 'WINNER\nPlayer ' .. player.getname() .. '\nscore: ' .. player.getscore(), -300 + 400 * player.getname(), 400, 0, 2, 2)
      else
        love.graphics.setColor(255, 0, 0)
        love.graphics.print( 'LOSER\nPlayer ' .. player.getname() .. '\nscore: ' .. player.getscore(), -300 + 400 * player.getname(), 400, 0, 2, 2)
      end
      love.graphics.setColor(255, 255, 255)
    end
  end
end

function love.update(dt)
  mqtt_client:handler()    
end