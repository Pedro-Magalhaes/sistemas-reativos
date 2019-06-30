
local id = node.chipid()
local broadcast = 0  -- mensagem do servidor de broadcast

-- mqtt topics
local listen = "love" -- postar respostas e cadastro
local publishTopic = "mcu" -- receber notificações 

local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)

gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

-- estados { "cadastro","aguardando", "respondendo", "respondido", "vitoria", "derrota" }
--[[
  cadastro: leds apagados e qualquer botão cadastra o mcu no jogo [publica para cadastro]
  aguardando: led verde aceso indicando que foi cadastrado e está aguardando o inicio [não pode publicar]
  respondendo: leds acesos e o click no botão indica a resposta botão 1 false e botão 2 true [publica resposta]
  respondido: led correspondente a resposta enviada aceso [não pode publicar]
  vitoria: led verde aceso [não pode publicar]
  derrota: led vermelho aceso [não pode publicar]
]]

estado = "cadastro"

local function publica(sw)
  m:publish(publishTopic, id..","..sw, 
  0, 0)
end

-- Recebe high ou low para cada led acendendo ou não cada um deles
local function changeLed(led1Status,led2Status)
  gpio.write(led1, gpio.led1Status);
  gpio.write(led2, gpio.led2Status);
end

local function fabricaBotao (botao)
  local ultimoClique = 0
  
  local function deb(time) -- funçao de debounce 
    if(time - ultimoClique > 250000) then -- microssegundos
      ultimoClique = time
      return true
    end
    return false
  end
  
  local function hitbt(estado,timeStamp) 
    if not deb(timeStamp) then 
      return 
    end
    if estado == "cadastro" or estado == "respondendo" then
      publica(botao)
      if estado == "respondendo" then
        estado = "respondido"
        local led1Stat = gpio.LOW
        local led2Stat = gpio.LOW
        if botao == "1" then 
          led1Stat = gpio.high
        else
          led2Stat = gpio.high
        end
        changeLed(led1Stat,led2Stat)
    end
  end
  return hitbt
end


function handleMessage(msg)
  print(msg) -- debbug
  if estado == "cadastro" then
    if msg == "ack" then -- confirmação de cadastro
      estado = "aguardando"
      changeLed(gpio.HIGH,gpio.LOW) -- verde ligado
    end
  elseif estado == "vitoria" or estado == "derrota" then
    if msg == "next" then 
      estado = "cadastro"
      changeLed(gpio.LOW,gpio.LOW) -- verde ligado
    end
  else
    if msg == "next" then
      estado = "respondendo"
      changeLed(gpio.HIGH,gpio.HIGH)
    elseif msg == id then
      estado = "vitoria"
      changeLed(gpio.HIGH,gpio.LOW)
    else
      estado = "derrota"
      changeLed(gpio.LOW,gpio.HIGH)
    end
  end
end

function parseMessage(rawMsg)
  print(message:match("([1-9]+)%s*,%s*([12])")) -- debbug
  return  message:match("([1-9]+)%s*,%s*([12])")
end

function subscribe (m, client) 
  m:subscribe(listen,0,  
       -- fç chamada qdo inscrição ok:
       function (client) 
         print("subscribe success")
         publica(id..",sub")
       end
  )

  m:on("message", 
    function(client, topic, data) 
      --print(topic .. ":" )
      dest, msg = parseMessage(data)
      if dest == "0" or dest == id then -- broadcast ou para o id do mcu
        handleMessage(msg)
      end
    end
  )
end

function connect (  ) 
  m = mqtt.Client("love", 120)
  -- conecta com servidor mqtt na porta 1883 (com o endereço esva dando erro)
  m:connect("test.mosquitto.org", 1883, 0,
    -- callback em caso de sucesso  
    function(client) 
      print("conected")
      subscribe(m,client)  
    end, 
    -- callback em caso de falha 
    function(client, reason) 
      print("failed reason: "..reason) 
    end)

end

wificonf = {  
  -- verificar ssid e senha  
  ssid = "Minharede",  
  pwd = "12345678B",  
  got_ip_cb = function (con)
                print("connecting")
                connect()
              end,
  save = false}

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)

gpio.trig(sw1, "down", fabricaBotao(1))
gpio.trig(sw2, "down", fabricaBotao(2))