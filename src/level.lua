map = {
  {1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,1},
  {1,0,2,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1},
}
mapWidth = #map[1]
mapHeight = #map

entities = {
  {id=1,x=3,y=3}, -- sprite index, x,y
}

player = {
  pos = {x=2.5,y=2.5},
  dir = 0,
  rotate = function(self, theta)
    self.dir = self.dir + theta
  end,
  translate = function(self, dx,dy)
    self.pos.x = self.pos.x+dx
    self.pos.y = self.pos.y+dy
  end,
  move = function(self, mode, n)
    local theta = self.dir
    if mode == 1 then theta = theta + math.pi/2 end
    local nx,ny = self.pos.x+n*math.cos(theta), self.pos.y+n*math.sin(theta)
    if map[math.floor(ny)][math.floor(nx)] == 0 then
      self.pos.x = nx
      self.pos.y = ny
    elseif map[math.floor(ny)][math.floor(self.pos.x)] == 0 then
      self.pos.y = ny
    elseif map[math.floor(self.pos.y)][math.floor(nx)] == 0 then
      self.pos.x = nx
    end
  end,
}

texSlice = {}
for i=1,64 do
  texSlice[i] = love.graphics.newQuad(i-1,0,1,64,64,64)
end

wallTextures = {
  love.graphics.newImage("assets/brick1.png"),
  love.graphics.newImage("assets/brick2.png"),
}

sprites = {
  love.graphics.newImage("assets/barrel.png"),
}
