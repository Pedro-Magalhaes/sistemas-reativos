function love.load()
  rets = {retangulo (50, 200, 200, 150), retangulo (350, 300, 200, 150)}
end

function naimagem (mx, my, x, y, w, h) 
  return (mx>x) and (mx<x+w) and (my>y) and (my<y+h)
end

function love.keypressed(key)
  for _, ret in pairs(rets) do
    ret.keypressed(key)
  end
end

function love.update (dt)
end

function love.draw()
  for _, ret in pairs(rets) do
    ret.draw()
  end
end

function retangulo (x,y,w,h)
  local originalx, originaly, rx, ry, rw, rh = x, y, x, y, w, h
  return {
    draw =
      function ()
        love.graphics.rectangle("line", rx, ry, rw, rh)
      end,
    keypressed =
      function (key)
        local mx, my = love.mouse.getPosition()
        if key == "down" and naimagem(mx, my, rx, ry, w, h)  then
          ry = ry + 10
        elseif key == "right"  and naimagem(mx, my, rx, ry, w, h)  then
          rx = rx + 10
        elseif key == "left"  and naimagem(mx, my, rx, ry, w, h)  then
          rx = rx - 10
        elseif key == "up"  and naimagem(mx, my, rx, ry, w, h)  then
          ry = ry - 10
        elseif key == "b"  and naimagem(mx, my, rx, ry, w, h)  then
          rx = originalx
          ry = originaly
        end
      end
  }
end
