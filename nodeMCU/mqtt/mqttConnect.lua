
local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2
local publish = "mcu"
local listen = "love"
local publisherId = publish
local contador = 0

local controleLed1
local controleLed2

function publica(sw)
  m:publish(publish, sw,
  0, 0)
 end

local criacontrolesw = function (sw)
  local lastPress = 0
  local tolerance = 200000 -- Micro-segundos!!
  local function cbchave (level, timestamp)
    if (timestamp - tolerance) > lastPress  then
      lastPress = timestamp
      print("mcu Publicando:  "..sw )
      publica(sw)
    end
  end
  return cbchave
end

local criacontroleLed = function (led)
  local apagado = true
  local function change()
    apagado = not apagado -- muda estado global
    if apagado then
      gpio.write(led, gpio.LOW);
    else
      gpio.write(led, gpio.HIGH);
    end
  end
  -- coloca pino do led em modo de saida
  gpio.mode(led, gpio.OUTPUT)
  -- apaga o led
  gpio.write(led, gpio.LOW)
  return change
end

-- coloca um sinal estavel nas chaves
gpio.mode(sw1,gpio.INT,gpio.PULLUP)
gpio.mode(sw2,gpio.INT,gpio.PULLUP)
-- cadastra as funcoes de callback para cada chave
gpio.trig(sw1, "down", criacontrolesw(sw1))
gpio.trig(sw2, "down", criacontrolesw(sw2))




function subscribe (m, client) 
  m:subscribe(listen,0,  
       -- fç chamada qdo inscrição ok:
       function (client) 
         print("subscribe success")
         controleLed1 = criacontroleLed(led1)
         controleLed2 = criacontroleLed(led2)
       end
  )

  m:on("message", 
    function(client, topic, data) 
      print(topic .. ":" )
      if data ~= nil then
        print(data)
        if data == 'a' then 
          controleLed1()
        else
          controleLed2()
        end
      end
    end
  )
end

function connect (  ) 
  m = mqtt.Client("meuCliente", 120)
  -- conecta com servidor mqtt na porta 1883 (com o endereço esva dando erro)
  m:connect("85.119.83.194", 1883, 0,
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
  pwd = "12345678A",  
  got_ip_cb = function (con)
                print("connecting")
                connect()
              end,
  save = false}

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)









