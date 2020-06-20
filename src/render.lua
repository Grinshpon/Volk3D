fov = math.pi/3
rayAngle = (fov)/320
dof = 20 -- depth of field (how far away a wall gets before not being rendered)

function raycaster()
  for i=1, 320 do
    local theta = simplifyAngle((i-1) * rayAngle + (player.dir - fov/2))
    local dist,h = shootRay(theta)
    dist = dist*math.cos(player.dir-theta)
    local y = height/dist
    if y > 0 then
      if h == 0 then
        love.graphics.setColor(1-dist/10,0,0)
      elseif h == 1 then
        love.graphics.setColor(0,0,1-dist/10)
      end
      love.graphics.line((i-1)*wratio()+wratio()/2, (100+y)*hratio() , (i-1)*wratio()+wratio()/2, (100-y)*hratio())
    end
  end
end

function drawMap()
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill", 0, 0, 900, 900)
  for y,row in ipairs(map) do
    for x in ipairs(row) do
      love.graphics.setColor(1,1,1)
      if map[y][x] == 1 then love.graphics.rectangle("fill", (x-1)*100, (y-1)*100, 100, 100) end
    end
  end
  for i=1, 320 do
    local theta = simplifyAngle((i-1) * rayAngle + (player.dir - fov/2))
    local x, y = player.pos.x, player.pos.y
    love.graphics.setColor(0,1,0)
    local d = shootRay(theta)
    if d == -1 then d = 0.5; love.graphics.setColor(1,1,0) end
    drawVec((x-1)*100, (y-1)*100, theta, d*100)
  end
  love.graphics.setColor(1,0,0)
  love.graphics.rectangle("fill", (player.pos.x-1)*100-10, (player.pos.y-1)*100-10, 20, 20)
end

function simplifyAngle(theta)
  local twoPi = 2*math.pi
  while theta > twoPi do
    theta = theta - twoPi
  end
  while theta < 0 do
    theta = theta + twoPi
  end
  return theta
end

--[[
function isQuadrant(theta, q)
  theta = simplifyAngle(theta)
  if q == 1 then
    return theta > 0 and theta < math.pi/2
  elseif q == 2 then
    return theta > math.pi/2 and theta < math.pi
  elseif q == 3 then
    return theta > math.pi and theta < (math.pi*3/2)
  elseif q == 4 then
    return theta > (math.pi*3/2) and theta < 2*math.pi
  end
end
--]]
--
function dist(x1,y1,x2,y2)
  return math.sqrt(math.pow(math.abs(x2-x1),2)+math.pow(math.abs(y2-y1),2))
end

function shootRay(theta)
  local tan = math.tan(theta)

  local distV, distH = nil,nil
  local x,y = player.pos.x,player.pos.y
  local dirX, dirY = math.cos(theta), math.sin(theta)
  local dx, dy = 0,0
  if dirX > 0 then
    dx = math.ceil(x)-x
  elseif dirX < 0 then
    dx = math.floor(x)-x
  end
  if dirY > 0 then
    dy = math.ceil(y)-y
  elseif dirY < 0 then
    dy = math.floor(y)-y
  end

  --distH, checking for horizontally aligned walls
  if dirY ~= 0 then
    local nx, ny = dy/tan,dy
    local stepX, stepY = 1/tan,1
    local offset=0
    if dirY < 0 then
      stepX = -1*stepX
      stepY = -1*stepY
      offset = 1
    end
    local curX, curY = x+nx, y+ny
    for _=1,dof do
      local intX, intY = math.floor(curX),curY-offset
      if intX > 0 and intX <= mapWidth and intY > 0 and intY <= mapHeight and map[intY][intX] > 0 then
        distH = dist(x,y,curX,curY)
        break
      end
      curX = curX + stepX
      curY = curY + stepY
    end
  end

  --distV, check for vertically aligned walls
  if dirX ~= 0 then
    local nx, ny = dx, dx*tan
    local stepX, stepY = 1,tan
    local offset=0
    if dirX < 0 then
      stepX = -1*stepX
      stepY = -1*stepY
      offset = 1
    end
    local curX, curY = x+nx, y+ny
    for _=1,dof do
      local intX, intY = curX-offset,math.floor(curY)
      if intX > 0 and intX <= mapWidth and intY > 0 and intY <= mapHeight and map[intY][intX] > 0 then
        distV = dist(x,y,curX,curY)
        break
      end
      curX = curX + stepX
      curY = curY + stepY
    end
  end

  --return shortest existing distance or -1
  --also return 0 if horizontal wall hit or 1 if vertical wall hit
  local dist,h
  if not distV then dist = distH; h = 0
  elseif not distH then dist = distV; h = 1
  elseif distV < distH then dist = distV; h = 1 else dist = distH; h = 0 end
  dist = dist or -1
  return dist,h
end

function drawVec(x, y, theta, r)
  yp = r*math.sin(theta)
  xp = r*math.cos(theta)
  love.graphics.line(x,y,x+xp,y+yp)
end

function renderMap()
  love.graphics.setColor(0.5,0.5,0.5)
  love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight()/2)
  raycaster()
  if showMap then drawMap() end
end
