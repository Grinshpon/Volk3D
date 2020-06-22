fov = math.pi/3
rayAngle = (fov)/320
dof = 20 -- depth of field (how far away a wall gets before not being rendered)

zBuffer = {}
for i=1,320 do
  zBuffer[i] = -1
end

function drawMap()
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill", 0, 0, 900, 900)
  for y,row in ipairs(map) do
    for x in ipairs(row) do
      love.graphics.setColor(1,1,1)
      if map[y][x] > 0 then love.graphics.rectangle("fill", (x-1)*100, (y-1)*100, 100, 100) end
    end
  end
  for i=1, 320 do
    local theta = simplifyAngle((i-1) * rayAngle + (player.dir - fov/2))
    --if i == 1 or i == 320 then print(i,simplifyAngle(player.dir-theta)) end
    local x, y = player.pos.x, player.pos.y
    love.graphics.setColor(0,1,0)
    local d = shootRay(theta)
    if d == -1 then d = 0.5; love.graphics.setColor(1,1,0) end
    drawVec((x-1)*100, (y-1)*100, theta, d*100)
  end
  love.graphics.setColor(1,0,0)
  love.graphics.rectangle("fill", (player.pos.x-1)*100-10, (player.pos.y-1)*100-10, 20, 20)
  love.graphics.rectangle("fill", (entities[1].x-1)*100-10, (entities[1].y-1)*100-10, 20, 20)
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

function quadrant(x,y)
  if x > 0 then
    if y > 0 then return 1 else return 4 end
  elseif x < 0 then
    if y > 0 then return 2 else return 3 end
  end
end

function ucAngle(x,y)
  if x == 0 then
    if y > 0 then return math.pi/2
    elseif y < 0 then return math.pi*3/2
    else return 0 end
  elseif y == 0 then
    if x >= 0 then return 0 else return math.pi end
  end
  local q = quadrant(x,y)
  if q == 1 then return math.atan(y/x)
  elseif q == 2 then return math.atan(y/x)+math.pi
  elseif q == 3 then return math.atan(y/x)+math.pi
  elseif q == 4 then return math.atan(y/x)+math.pi*2
  end
end

function dist(x1,y1,x2,y2)
  return math.sqrt(math.pow(math.abs(x2-x1),2)+math.pow(math.abs(y2-y1),2))
end

function sqDist(x1,y1,x2,y2)
  return math.pow(math.abs(x2-x1),2)+math.pow(math.abs(y2-y1),2)
end

function shootRay(theta)
  local tan = math.tan(theta)

  local distV, distH = nil,nil
  local idV,idH

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
  local curXH,curXV,curYH,curYV

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
    curXH, curYH = x+nx, y+ny
    for _=1,dof do
      local intX, intY = math.floor(curXH),curYH-offset
      if intX > 0 and intX <= mapWidth and intY > 0 and intY <= mapHeight and map[intY][intX] > 0 then
        distH = dist(x,y,curXH,curYH)
        idH = map[intY][intX]
        break
      end
      curXH = curXH + stepX
      curYH = curYH + stepY
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
    curXV, curYV = x+nx, y+ny
    for _=1,dof do
      local intX, intY = curXV-offset,math.floor(curYV)
      if intX > 0 and intX <= mapWidth and intY > 0 and intY <= mapHeight and map[intY][intX] > 0 then
        distV = dist(x,y,curXV,curYV)
        idV = map[intY][intX]
        break
      end
      curXV = curXV + stepX
      curYV = curYV + stepY
    end
  end

  --return shortest existing distance or -1
  --also return 0 if horizontal wall hit or 1 if vertical wall hit
  --also return id of wall
  --also return slice of wall hit (1-64)
  local dist,wall,id,slice
  if not distV then dist = distH; wall = 0; id=idH
  elseif not distH then dist = distV; wall = 1; id=idV
  elseif distV < distH then dist = distV; wall = 1; id=idV else dist = distH; wall = 0; id=idH end
  dist = dist or -1

  if wall == 0 then
    slice = curXH*64
  elseif wall == 1 then
    slice = curYV*64
  end
  slice = math.floor(slice%64)+1

  return dist,wall,id,slice
end

function drawVec(x, y, theta, r)
  yp = r*math.sin(theta)
  xp = r*math.cos(theta)
  love.graphics.line(x,y,x+xp,y+yp)
end

function render()
  love.graphics.setColor(0.4,0.4,0.4)
  love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight()/2)
  raycaster()
  renderSprites()
  if showMap then drawMap() end
end

function renderLine(i,h)
  love.graphics.line((i-1)*wratio()+wratio()/2, (100+h)*hratio() , (i-1)*wratio()+wratio()/2, (100-h)*hratio())
end

function renderSlice(i,dist,id,slice) --slice todo
  if slice > 0 and slice <= 64 then
    love.graphics.draw(wallTextures[id],texSlice[slice], (i-1)*wratio()+wratio()/2,(100-height/dist)*hratio(), 0,wratio(),6.25/dist*hratio())
  end
end

function raycaster()
  for i=1, 320 do
    local theta = simplifyAngle((i-1) * rayAngle + (player.dir - fov/2))
    local dist,wall,id,slice = shootRay(theta)
    dist = dist*math.cos(player.dir-theta)
    zBuffer[i] = dist
    local sHeight = height/dist
    if sHeight > 0 then
      local c = 1-dist/20
      if wall == 0 then
        c = c-0.1
        love.graphics.setColor(c,0,0)
      elseif wall == 1 then
        love.graphics.setColor(0,0,c)
      end
      if textureMode then
        love.graphics.setColor(c,c,c,1)
        renderSlice(i,dist,id,slice)
      else
        renderLine(i,sHeight)
      end
    end
  end
end

function fartherEntity(e1,e2)
  return sqDist(player.pos.x,player.pos.y,e1.x,e1.y) > sqDist(player.pos.x,player.pos.y,e2.x,e2.y)
end

function renderSprites()
  -- sort entities farthest to closest, then draw according to zbuffer and painter's algo
  table.sort(entities,fartherEntity)
  for i,s in ipairs(entities) do
    local vx,vy = s.x-player.pos.x, s.y-player.pos.y
    local vt = ucAngle(vx,vy)
    --local vt = math.atan(vy/vx)
    local theta = simplifyAngle(player.dir-vt)

    love.graphics.setColor(0.1,0.8,0.1)
    love.graphics.print(theta,1000,10)
    love.graphics.print(vt,1000,60)
    love.graphics.print(simplifyAngle(player.dir),1000,110)
  end
  for i,d in ipairs(zBuffer) do

  end
end
