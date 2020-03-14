local Animation = {}
Animation.__index = Animation

function Animation.createController()
  return setmetatable({
      ids = {},
      duration = {},
      current = {},
      frames = {},
      curve = {},
      tweener = {},
      running = {},
      reversible = {},
      reverse = {},
      }, Animation)
end

function Animation.register(self, params) -- *1
  local registered = false
  for i = 1, #self.ids do
    if self.ids[i] == params.id then
      registered = true
      break
    end
  end
  if not registered then
    table.insert(self.ids, params.id)
  end
  self.duration[params.id] = params.duration
  self.current[params.id] = 1
  self.running[params.id] = false
  self.curve[params.id] = params.curve
  self.reversible[params.id] = params.reversible
  self.reverse[params.id] = false
  self.tweener[params.id] = params.tweener
  self:_constructFrames(params.id)
end




function Animation.update(self)
  for i = 1, #self.ids do
    local id = self.ids[i]
    if self.running[id] then
      if not self.reversible[id] then
        self.current[id] = self.current[id] + 1
        if self.current[id] >= #self.frames[id] then -- *4
          self:pause(id)
          self:reset(id)
        end
      else
        if not self.reverse[id] then
          self.current[id] = self.current[id] + 1
          if self.current[id] >= #self.frames[id] then
            self:pause(id)
            self:flip(id)
          end
        else
          self.current[id] = self.current[id] - 1
          if self.current[id] <= 1 then
            self:pause(id)
            self:flip(id)
          end
        end
      end
      self.tweener[id][1][1] = self.frames[id][self.current[id]]
    end
  end
end

function Animation.play(self, id)
  self.running[id] = true
end

function Animation.pause(self, id)
  self.running[id] = false
end

function Animation.reset(self, id)
  self.current[id] = 1
end

function Animation.flip(self, id)
  self.reverse[id] = not self.reverse[id]
end

function Animation._constructFrames(self, id)
  local init, fin = self.tweener[id][2], self.tweener[id][3]
  local cFn, cI, cF = self.curve[id][1], self.curve[id][2], self.curve[id][3]
  local numFrames = math.ceil(self.duration[id] * 60)
  local cInc = (cF - cI) / numFrames
  local range = fin - init
  
  self.frames[id] = {0}
  local frames = self.frames[id]
  local cSum = 0
  
  j = cI
  
  for i = 2, numFrames+1 do
    cSum = cSum + cFn(j)
    frames[i] = cFn(j)
    j = j + cInc
  end
  for i = 2, numFrames+1 do
    frames[i] = frames[i-1] + frames[i] / cSum
  end
  for i = 1, numFrames+1 do
    frames[i] = init + frames[i] * range
  end
end


return Animation

--------------------
----- COMMENTS -----
--------------------

--[[ 

*1: params = {id, duration, curve, tweener} *2 *3

*2: curve = {animFn, initial, final}

*3: tweener = {{variable}, initial, final}

*4: For now, after animation ends, pause and reset the animation.
    
--]]