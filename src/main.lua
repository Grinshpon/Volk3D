require "setup"
require "level"
require "render"

showMap = false
textureMode = true

function love.load()
  --print("Map: "..tostring(mapWidth).."x"..tostring(mapHeight))
  love.graphics.setBackgroundColor(0.7,0.7,0.7)
  love.graphics.setLineWidth(wratio())
end

function love.update(dt)
  if love.keyboard.isDown("left") then player:rotate(-rayAngle*350*dt) end
  if love.keyboard.isDown("right") then player:rotate(rayAngle*350*dt) end
  if love.keyboard.isDown("w") then player:move(0, 2*dt) end
  if love.keyboard.isDown("s") then player:move(0, -2*dt) end
  if love.keyboard.isDown("a") then player:move(1, -2*dt) end
  if love.keyboard.isDown("d") then player:move(1, 2*dt) end
  if love.keyboard.isDown("escape") or love.keyboard.isDown("q") then love.event.quit() end
end

function love.keypressed(key)
  if key == "m" then showMap = not showMap
  elseif key == "t" then textureMode = not textureMode
  end
end

function love.draw()
  render()
  love.graphics.setColor(0.1,0.8,0.1)
  love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end
