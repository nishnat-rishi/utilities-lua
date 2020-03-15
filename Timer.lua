local Timer = {}
Timer.__index = Timer

function Timer.create()
  return setmetatable({
    ids = {}, 
    duration = {}, 
    remaining = {}, 
    callback = {}, 
    periodic = {},
    _trash = {},
    _pendingRegistrations = {},
  }, Timer)
end

function Timer.register(self, params)
  for i = 1, #self.ids do
    if self.ids[i] == params.id then
      table.insert(self._pendingRegistrations, params) -- *6
      return
    end
  end
  table.insert(self.ids, params.id)
  self:_rawRegister(params)
end

function Timer.update(self, dt)
  for i = 1, #self.ids do
    local id = self.ids[i]
    self.remaining[id] = self.remaining[id] - dt
    if self.remaining[id] <= 0 then
      self.callback[id]()
      if self.periodic[id] then
        self.remaining[id] = self.duration[id]
      else
        table.insert(self._trash, id)
      end
    end
  end
  if #self._trash > 0 then
    self:_clear()
  end
  if #self._pendingRegistrations > 0 then
    self:registerPending()
  end
end

function Timer._rawRegister(self, params)
  self.duration[params.id] = params.duration
  self.remaining[params.id] = params.duration
  self.callback[params.id] = params.callback
  self.periodic[params.id] = params.periodic
end

function Timer._clear(self)
  for i = 1, #self._trash do
    local id = self._trash[i]
    self.duration[id] = nil
    self.remaining[id] = nil
    self.callback[id] = nil
    self.periodic[id] = nil
    table.remove(self.ids, i)
  end
end

function Timer._registerPending(self)
  for i = #self._pendingRegistrations, 1, -1 do
    self:_rawRegister(self._pendingRegistrations[i])
    table.remove(self._pendingRegistrations, i)
  end
  
end

return Timer

--------------------
----- COMMENTS -----
--------------------

--[[ 

*4: params = {id, duration, callback, periodic}
    
*6: If the ID is already taken, just the current params onto a 'pending'
    registrations table. After the update loop is finished and trash is cleared,
    items from this pending table will be registered onto the existing id.
    
--]]