local Timer = {}

function Timer.create()
  return {
    ids = {}, 
    duration = {}, 
    remaining = {}, 
    callbacks = {}, 
    periodic = {},
    _trash = {},
    register = function(self, params) -- *1 *2 *3 *4
        local registered = false
        for i = 1, #self.ids do
          if self.ids[i] == params.id then
            registered = true
            break
          end
        end
        if not registered then
          table.insert(self.ids, params.id)
        end -- *5
        self.duration[params.id] = params.duration
        self.remaining[params.id] = params.duration
        self.callbacks[params.id] = params.callback
        self.periodic[params.id] = params.periodic
      end,
    update = function(self, dt) 
        for i = 1, #self.ids do
          local id = self.ids[i]
          self.remaining[id] = self.remaining[id] - dt
          if self.remaining[id] <= 0 then
            self.callbacks[id]()
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
      end,
    _clear = function(self)
      for i = 1, #self._trash do
        local id = self._trash[i]
        self.duration[id] = nil
        self.remaining[id] = nil
        self.callbacks[id] = nil
        self.periodic[id] = nil
        table.remove(self.ids, i)
      end
    end,
    }
end

return Timer

--------------------
----- COMMENTS -----
--------------------

--[[ 

*1: This can create race condition issues -> registering a new timer while 
    inside the update-for-loop! Try using a coroutine as the register function!
    It will be suspended before the update-for-loop and resumed after the 
    update-for-loop, before the trash is cleared!

*2: For now, to be safe, only register all timers in the love.load() function! 
    This way, no update-for-loop conflicts will arise.

*3: Try to yield the register function right after adding the repeated ID to 
    trash and before registering the new timer. This register function should 
    resume control of the update function!

*4: params = {id, duration, callback, periodic}

*5: Code till this point seems to be replaceable by a set implementation (since
    all that's happening here is prevention of a value from being repeated!) 
    But in the future, special handling of existing timers will be required 
    (for example registering a new timer while inside the update-for-loop).
--]]