

--local contador = 0

--function publica()
--  m:publish("alos", "boa tarde ".. contador ,
--  0, 0, function (c) print ("enviou!") end)
--end


function subscribe (m, client) 
  m:subscribe("alos",0,  
       -- fç chamada qdo inscrição ok:
       function (client) 
         print("subscribe success") 
       end
  )

  m:on("message", 
    function(client, topic, data) 
      --contador = contador + 1  
      print(topic .. ":" )
      publica()
      if data ~= nil then print(data) end
    end
  )
end

function connect (  ) 
  m = mqtt.Client("clientid", 120)
  -- conecta com servidor mqtt na máquina 'ipbroker' e porta 1883:
  m:connect("test.mosquitto.org", 1883, 0,
    -- callback em caso de sucesso  
    function(client) 
      print("subscribed")
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

print("Alo")

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)









