local ssid = "Minharede"
local pwd = "12345678B"

-- lista de não permitidos
proibido = {
	"facebook","youtube","torrent"
}

srv = net.createServer(net.TCP)

-- html da pagina inicial
home = [[
	<html>
	<body>
	<h1><u>PUC Rio</u></h1>
	<h2><i>ESP8266 Web Proxy</i></h2>
			<form>
				<input type="text" name="site"><br><br>
			<input type="submit" value="Submit">
	</form>
	</body>
	</html>
]]

local function urldecode (url)
	return url:gsub("%%(%x%x)", function(x)
								  return string.char(tonumber(x, 16))
								end)
end

-- Função que trata as requisições
function receiver(sck, request)
  print("recebeu: " .. request)
  response = home
  -- analisa pedido para encontrar valores enviados
  local _, _, method, path, vars = string.find(request, "([A-Z]+) ([^?]+)%?([^ ]+) HTTP");

  local _GET = {}
  if (vars ~= nil)then
	print("vars", vars)
	vars = urldecode (vars) --decode para tirar hexadecimal da url
	-- pegamos a url digitada (variavel "site")
	for k,v in string.gmatch(vars, "(site)=([://%w%.]+)&*") do
	  if not v:find("www.") then -- adicionando "www." se não houver
	    v= "www." .. v
	  end
	  if not v:find("http://") then -- adicionando "http://" se não houver
	  	v = "http://" .. v
	  end
	  _GET[k] = v
	end
	response = [[
		<html>
		<body>		
		<a href="]] .. _GET.site .. [["> <h1><u>Permitido</u></h1> </a>
		</form>
		</body>
		</html>
		]]
	for _,s in pairs(proibido) do
		if( _GET.site:find(s) ) then -- se for proibido alteramos a tela para de não permitido
		  response = [[
			<html>
			<body>
			<a href="/"> <h1><u>Nao permitido</u></h1> </a>
			</form>
			</body>
			</html>
			]]
			break
		end
	end
  end	
	
	sck:send(response, 
           function()  -- callback: fecha o socket qdo acabar de enviar resposta
             print("respondeu") 
             sck:close() 
    end)
		
end


-- Conexão com wifi
wificonf = {  
	-- verificar ssid e senha  
	ssid = ssid,  
	pwd = pwd,  
	got_ip_cb = function (con)
					print ("meu IP: ", con.IP)
					if srv then
					srv:listen(80, function(conn)
						print("CONN")
						conn:on("receive", receiver)
						end)
					end
					
					addr, port = srv:getaddr()
					print(addr, port)
					print("servidor inicializado.")
				end,
	save = false}

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)
