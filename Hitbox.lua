local Hitbox = {}
Hitbox.__index = Hitbox

function Hitbox.createController()
  return setmetatable({
    ids = {},
    object = {},
    entered = {},
    _trash = {},
    _pendingRegistrations = {},
  }, Hitbox)
end

function Hitbox.register(self, params) -- *1
    for id, _ in pairs(self.ids) do
      if id == params.id then
        self._pendingRegistrations[id] = params
        return
      end
    end
    self.ids[params.id] = true
    self:_rawRegister(params)
  end
  
  function Hitbox.deregister(self, id)
    self._trash[id] = true
  end

function Hitbox.update(self, x, y) -- *3
  for id, _ in pairs(self.ids) do
    local obj = self.object[id]
    local coll = (x >= obj.x and x <= obj.x + obj.width) and (y >= obj.y and y <= obj.y + obj.height)
    if coll ~= self.entered[id] then
      if self.entered[id] then
        self.entered[id] = false
        obj:onExit()
      else
        self.entered[id] = true
        obj:onEnter()
      end
    end
  end
  if next(self._trash) then
    self:_clear()
  end
  if next(self._pendingRegistrations) then
    self:_registerPending()
  end
end

function Hitbox._rawRegister(self, params)
  self.object[params.id] = params.object
  self.entered[params.id] = false
end

function Hitbox._clear(self)
  for id, _ in pairs(self._trash) do
    self.object[id] = nil
    self.entered[id] = nil
    self.ids[id] = nil
    self._trash[id] = nil
  end
end

function Hitbox._registerPending(self)
  for id, params in pairs(self._pendingRegistrations) do
    self:_rawRegister(params)
    self._pendingRegistrations[id] = nil
  end
end

return Hitbox

--------------------
----- COMMENTS -----
--------------------

--[[ 

*1: params = {id, object} -- object is Draw-able (... x, y, width, height ...)

*3: This update function CAN be placed inside love.mousemoved(). Seems smart
    to not call this expensive(ish) function until the pointer moves. But the 
    side effect of this would be when the item moves from under the pointer 
    while the pointer remains still, onExit won't be called till the pointer is 
    moved again.

--]]