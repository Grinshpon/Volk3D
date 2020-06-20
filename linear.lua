Linear = {}

function Linear.mat(o)
  return {
    typeof = "matrix",
    rows = #o,
    cols = #o[1],
    mat = o,
    get = Matrix_get,
    set = Linear_set,
  }
end

local function Linear_get(self,r,c)
  if self.typeof == "matrix" then
    return self.mat[r][c]
  elseif self.typeof == "vector" then
    return self.vec[r]
  else
    error "Linear_get"
  end
end

local function Linear_set(self,r,c,v)
  if self.typeof == "matrix" then
    self.mat[r][c] = v
  elseif self.typeof == "vector" then
    self.vec[r] = c
  else
    error "Linear_get"
  end
end

function Linear.vec(o)
  return {
    typeof = "vector",
    len = #o,
    vec = o,
    get = Linear_get,
    set = Linear_set,
    coords = function(self) return self:get(1), self:get(2); end,
    angle = function(self) return math.atan(self:get(2)/self:get(1)) end,
    rotate = function(self,theta)
      local x,y = self:get(1), self:get(2)
      self:set(1, x*math.cos(theta)-y*math.sin(theta))
      self:set(2, x*math.sin(theta)+y*math.cos(theta))
    end,
  }
end

return Linear
