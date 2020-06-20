love.window.setTitle "Volk";
love.graphics.setDefaultFilter("nearest","nearest")
love.graphics.setNewFont(40)

love.window.setFullscreen(false)
love.window.setMode(0,0,{resizable=false})

love.window.setMode(1920,1440,{resizable = false})

width, height = 320, 200 -- can change up to 640, 600 if feel like it

function sratio()
  return wratio(), hratio()
end

function wratio()
  return love.graphics.getWidth()/width
end

function hratio()
  return love.graphics.getHeight()/height
end
