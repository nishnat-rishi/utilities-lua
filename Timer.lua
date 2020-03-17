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
  for id, _ in pairs(self.ids) do -- *3
    if id == params.id then
      self._pendingRegistrations[id] = params -- *6
      return
    end
  end
  self.ids[params.id] = true
  self:_rawRegister(params)
end

function Timer.deregister(self, id)
  self._trash[id] = true
end

function Timer.update(self, dt)
  for id, _ in pairs(self.ids) do
    if self.remaining[id] > 0 then
      self.remaining[id] = self.remaining[id] - dt 
    else
      self.callback[id]()
      if self.periodic[id] then
        self.remaining[id] = self.duration[id]
      else
        self:deregister(id)
      end
    end
  end
  if next(self._trash) then -- *5
    self:_clear()
  end
  if next(self._pendingRegistrations) then
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
  for id, _ in pairs(self._trash) do
    self.duration[id] = nil
    self.remaining[id] = nil
    self.callback[id] = nil
    self.periodic[id] = nil
    self.ids[id] = nil
    self._trash[id] = nil -- *2
  end
end

function Timer._registerPending(self)
  for id, params in pairs(self._pendingRegistrations) do
    self:_rawRegister(params)
    self._pendingRegistrations[id] = nil
  end
end

return Timer

--------------------
----- COMMENTS -----
--------------------

--[[ 

*1: One performance increasing change can be to give the user the ability to
    dispose of the timer instead of it happening automatically. This runs the
    risk of unwary users not handling disposal at all and thus letting the 
    memory cost go ham. But it also affords careful users the opportunity to
    optimize their code.

*2: The iterator maintains its own state, so we can safely assign nil to 
    self._trash[id].

*3: Rethink the implications of 'self.ids[params.id] = true' and perhaps see 
    what deep changes are in order (instead of just a naive refactoring i.e. 
    loop conversions and minor assignment changes).

    Potential (brainstormed) implications:

    - Trashcans become trivial. (Somehow no trashcan would be required, simply
      assign self.ids[id] = nil and the pairs loop will keep on chugging along)

    - A separate _pendingRegistrations table is unnecessary! Simply overwrite.
      (But this may cause race conditions within the update-for-loop! So think
      this decision through carefully.)

*4: params = {id, duration, callback, periodic}

*5: Optimization trick. We won't call self._clear() till there is something to
    clear! This reduces one function call (in a function which is called 60
    times a second!)
    
*6: If the ID is already taken, just attach the current params onto a 'pending'
    registrations table. After the update loop is finished and trash is cleared,
    items from this pending table will be registered onto the existing id.
    
--]]