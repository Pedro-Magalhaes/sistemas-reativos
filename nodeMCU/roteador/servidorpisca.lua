
srv = net.createServer(net.TCP)

function receiver(sck, request)
  print("recebeu: " .. request)

  -- analisa pedido para encontrar valores enviados
  local _, _, method, path, vars = string.find(request, "([A-Z]+) ([^?]+)%?([^ ]+) HTTP");
  -- se não conseguiu casar, tenta sem variáveis
  if(method == nil)then
    _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
  end
  
  local _GET = {}
  
  if (vars ~= nil)then
    for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
      _GET[k] = v
    end
  end


  --local action = actions[_GET.pin]
  --if action then action() end

  

	local buf = [[
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
	
	local bufOK = [[
	<html>
	<body>
	
	<a href="www.google.com"> <h1><u>Seguro</u></h1> </a>
	</form>
	</body>
	</html>
	]]
	
	local bufnotOK = [[
	<html>
	<body>
	<h1><u>Não seguro</u></h1>			
	</body>
	</html>
	]]
	
	
	sck:send(bufOK, 
           function()  -- callback: fecha o socket qdo acabar de enviar resposta
             print("respondeu") 
             sck:close() 
    end)
		
end

if srv then
  srv:listen(80, function(conn)
      print("CONN")
      conn:on("receive", receiver)
    end)
end

addr, port = srv:getaddr()
print(addr, port)
print("servidor inicializado.")

