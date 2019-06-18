
local id = node.chipid()
print("nodeid = "..id)
local listen = "love"
local publishTopic = "mcu"

function publica(sw)
  m:publish(listen, sw, -- para testes em listen
  0, 0)
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
  pwd = "12345678B",  
  got_ip_cb = function (con)
                print("connecting")
                connect()
              end,
  save = false}

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)