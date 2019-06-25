
local id = node.chipid()
print("nodeid = "..id)
local listen = "love"
local publishTopic = "mcu"
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


function publica(sw)
  m:publish(publishTopic, id..","..sw, -- para testes em listen
  0, 0)
 end

local function fabricaBotao (botao)
  local ultimoClique = 0
  
  local function deb(time) 
    if(time - ultimoClique > 250000) then
      ultimoClique = time
      return true
    end
    return false
  end
  
  local function hitbt(estado,timeStamp) 
    if not deb(timeStamp) then 
      return 
    end
    publica(botao)   
  end
  return hitbt
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
      print(topic .. ":" )
      if data ~= nil then
        print(data)
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