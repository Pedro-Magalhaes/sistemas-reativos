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

local tempoaceso = 200000
local seqrodada = {}
local tamsequsuario = 0
local tamseq = 5
local ultimoClique = 0
local cbchave1

local function deb(time) 
  if(time - ultimoClique > 250000) then
    ultimoClique = time
    return true
  end
  return false
end

local function acendeLed(led)
  gpio.write(led, gpio.HIGH)
  tmr.delay(3*tempoaceso)
  gpio.write(led, gpio.LOW)
  tmr.delay(2*tempoaceso)
end

local function showresult(estado)
  local luz
  if estado then
    luz = 6
    print("parabens voce acertou")
  else
    luz = 3
    print("Errrrrrrrrrrrou")
  end
  for i=1,4 do
    acendeLed(luz)
  end
  print("Reiniciando...")
  gpio.trig(sw1, "down", cbchave1)
  gpio.trig(sw2)
end


local function fabricaBotao (botao)
   local function hitbt(estado,timeStamp) 
    if not deb(timeStamp) then return end
    acendeLed(3*botao)
    if seqrodada[tamsequsuario+1] ~= botao then
      showresult(false)
    end
    tamsequsuario = tamsequsuario + 1
    if tamsequsuario == tamseq then
      showresult(true)
    end
  end
  return hitbt
end


local function geraseq (semente)
  tamsequsuario = 0
  print ("veja a sequencia:")
  tmr.delay(2*tempoaceso)
  print ("(" .. tamseq .. " itens)")
  math.randomseed(semente)
  for i = 1,tamseq do
    seqrodada[i] = math.floor(math.random(1.5,2.5))
    print(seqrodada[i])
    acendeLed(3*seqrodada[i])
  end
  print ("agora (seria) sua vez:")
  gpio.trig(sw1, "down", fabricaBotao(1))
  gpio.trig(sw2, "down", fabricaBotao(2))
end

cbchave1 =  function (_,contador)
  -- corta tratamento de interrupcoes
  -- (passa a ignorar chave)
  gpio.trig(sw1)
  -- chama funcao que trata chave
  geraseq (contador)
end



gpio.trig(sw1, "down", cbchave1)



