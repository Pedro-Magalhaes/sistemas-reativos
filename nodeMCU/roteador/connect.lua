wificonf = {  
  -- verificar ssid e senha  
  ssid = "Minharede",  
  pwd = "12345678B",  
  got_ip_cb = function (con)
                print ("meu IP: ", con.IP)
              end,
  save = false}

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)
