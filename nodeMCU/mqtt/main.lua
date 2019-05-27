local mqtt = require("mqtt_library")

local publish = "love"
local listen = "mcu"

function mqttcb(topic, message)
   if message == '1' then
     controle = true
   else
     controle = false
   end
   
end

function love.keypressed(key)
  if key == 'a' then
    mqtt_client:publish(publish, "a")
  elseif key == 'b' then
    mqtt_client:publish(publish, "b")  
  end
end

function love.load()
  controle = false
  mqtt_client = mqtt.client.create("85.119.83.194", 1883, mqttcb)
  mqtt_client:connect("love")
  mqtt_client:subscribe({listen})
end

function love.draw()
   if controle then
     love.graphics.rectangle("line", 10, 10, 200, 150)
   end
end

function love.update(dt)
  mqtt_client:handler()
end
  