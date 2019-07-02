
local id = node.chipid()
local broadcast = 0  -- mensagem do servidor de broadcast

-- mqtt topics
local listen = "love" -- postar respostas e cadastro
local publishTopic = "mcu" -- receber notificações 

local led1 = 3
local led2 = 6
local sw1 = 1  -- resposta false
local sw2 = 2 -- resposta true

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)

gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)

--[[ "estados" do node MCU
  cadastro: leds apagados e qualquer botão cadastra o mcu no jogo [publica para cadastro]
  respondendo: leds acesos e o click no botão indica a resposta botão 1 false e botão 2 true [publica resposta]
  respondido: led correspondente a resposta enviada aceso 
  vitoria: led verde aceso 
  derrota: led vermelho aceso 
]]


local function publica(sw)
  m:publish(publishTopic, id..","..sw, 
  0, 0)
end

-- Recebe high ou low para cada led acendendo ou não cada um deles
local function changeLed(led2Status,led1Status)
  gpio.write(led1, led1Status);
  gpio.write(led2, led2Status);
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
  
  local function hitbt(state,timeStamp) 
    if not deb(timeStamp) then 
      return 
    end
    publica(botao)      
    local led1Stat = gpio.LOW
    local led2Stat = gpio.LOW
    if botao == 1 then 
      led1Stat = gpio.HIGH
    else
      led2Stat = gpio.HIGH
    end
    changeLed(led2Stat,led1Stat)

  end -- end hitbt

  return hitbt
end


function handleMessage(msg)
  print("handleMessage: ",msg) -- debbug  
  if msg == "responder" then
    changeLed(gpio.HIGH,gpio.HIGH)
  elseif msg == "vitoria" then
    changeLed(gpio.HIGH,gpio.LOW)
  elseif msg == "derrota" then 
    changeLed(gpio.LOW,gpio.HIGH)
  else
    changeLed(gpio.LOW,gpio.LOW)
  end
  
end

function parseMessage(rawMsg)
  return  rawMsg:match("([0-9]+)%s*,%s*(%w*)")
end

function subscribe (m, client) 
  m:subscribe(listen,0,  
       -- fç chamada qdo inscrição ok:
       function (client) 
         print("subscribe success")
       end
  )

  m:on("message", 
    function(client, topic, data) 
      print(topic .. ":" )
      dest, msg = parseMessage(data)
      dest = tonumber(dest)
      print("dest,msg ", dest == 0, dest==id,dest,id,msg)
      if dest == 0 or dest == id then -- broadcast ou para o id do mcu
        handleMessage(msg)
      end
    end
  )
end

function connect (  ) 
  m = mqtt.Client("mcu"..id, 120)
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
