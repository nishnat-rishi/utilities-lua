local event = {
  _pending = {},
}

function event:dispatch(event)
  table.insert(self._pending, event)
end

function event:handle(event)
  -- to be defined by user
end

function event:update(dt)
  local k, e = next(self._pending)
  if e then -- event exists
    table.remove(self._pending, k)
    self:handle(e)
  end
end

return event