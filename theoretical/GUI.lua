_GUIHitbox = require('Hitbox')

GUI = {}
GUI.__index = GUI

GUI.Base = {
  RECTANGLE = 1,
}

GUI.Alignment = {
  CENTER = 1,
  TOP = 2,
  TOP_RIGHT = 3,
  RIGHT = 4,
  BOTTOM_RIGHT = 5,
  BOTTOM = 6,
  BOTTOM_LEFT = 7,
  LEFT = 8,
  TOP_LEFT = 9,
}

function GUI.create(params)
  return setmetatable({
    ids = {},
    template = {},
    _hb = {},
    _dragReadyDepth = {},
    _windowDimensions = {width = params.windowDimensions.width, height = params.windowDimensions.height}
  }, GUI)
end

function GUI.construct(self, id, initCoordinates, template)
  self.ids[id] = true
  self._hb[id] = _GUIHitbox.createController()
  --self.template[id] = {}

  local _drawingTemplate = {}
  local _remainingPixels = {}
  _drawingTemplate[0] = {x = 0, y = 0, width = self._windowDimensions.width, height = self._windowDimensions.height}
  local parentIndex = 0
  local i = 1
  local depth = 1
  while template do
    GUI._errorCheck{
      condition = template.base == GUI.Base.RECTANGLE and (not template.width) or (not template.height),
      message = 'height & width of a RECTANGLE is required!'
    }

    -- Create drawing template
    _drawingTemplate[i] = {
      parent = parentIndex, 
      x = i == 1 and initCoordinates.x or 0,
      y = i == 1 and initCoordinates.y or 0,
      width = template.width,
      height = template.height,
      draw = GUI._drawFunctionByTemplate(template)
    }

    -- Alignment actions.
    GUI._alignElement(_drawingTemplate, i, template)

    -- Gesture actions.
    self:_gesturizeElement(id, depth, _drawingTemplate, i, template)
    -- Update remaining pixels
    _remainingPixels[i] = {}
    _remainingPixels[i].width = template.width
    _remainingPixels[i].height = template.height
    if _remainingPixels[parentIndex] ~= nil then
      -- Test width/height against parent
      GUI._errorCheck{
        condition = _remainingPixels[parentIndex].width < _drawingTemplate[i].x_offset() + _drawingTemplate[i].width,
        message = 'child\'s width exceeds parent\'s width. (child id: ' .. (template.id and ('\'' .. template.id .. '\'') or (i .. ' (internal)')) .. ')',
      }
      _remainingPixels[parentIndex].width = _remainingPixels[parentIndex].width - (_drawingTemplate[i].x_offset() + _drawingTemplate[i].width) -- REMOVE the offset subtractions to be TRUE. Centered multiple widgets will only then make sense!
      GUI._errorCheck{
      condition = _remainingPixels[parentIndex].height < _drawingTemplate[i].y_offset() + _drawingTemplate[i].height,
      message = 'child\'s height exceeds parent\'s height. (child id: ' .. (template.id and ('\'' .. template.id .. '\'') or (i .. ' (internal)')) .. ')',
      }
      _remainingPixels[parentIndex].height = _remainingPixels[parentIndex].height - (_drawingTemplate[i].y_offset() + _drawingTemplate[i].height) -- REMOVE the offset subtractions to be TRUE. Centered multiple widgets will only then make sense!
    end

    parentIndex = parentIndex + 1 -- This is separate from i for when we finally add 'children'
    i = i + 1
    template = template['child']
  end
  self.template[id] = _drawingTemplate
end

function GUI.draw(self, id)
  local k, element = next(self.template[id])
  k, element = next(self.template[id], k)
  element:draw()
  while next(self.template[id], k) do
    k, element = next(self.template[id], k)
    element.x = self.template[id][element.parent].x + element.x_offset()
    element.y = self.template[id][element.parent].y + element.y_offset()
    element:draw()
  end
  -- for i = 1, #self.template[id] do
  --   self.template[id][i].draw(self.template[id][self.template[id][i].parent].x_offset + self.template[id][i].x_offset, self.template[id][self.template[id][i].parent].y_offset + self.template[id][i].y_offset)
  -- end
end

function GUI.update(self, id)
  self._hb[id]:update(love.mouse.getX(), love.mouse.getY())
end

function GUI.mousepressed(self, x, y, button, istouch, presses)
  if next(self._dragReadyDepth) then
    self.beingDraggedID, self.beingDraggedDepth = next(self._dragReadyDepth)
    self.template[self.beingDraggedID][self.beingDraggedDepth].onDragBegin()
  end
end

function GUI.mousereleased(self, x, y, button, istouch, presses)
  if next(self._dragReadyDepth) then
    self.template[self.beingDraggedID][self.beingDraggedDepth].onDragEnd()
    self.beingDraggedID, self.beingDraggedDepth = nil, nil
  end
end

function GUI.mousemoved(self, x, y, dx, dy, presses)
  if self.beingDraggedID then
    self.template[self.beingDraggedID][self.beingDraggedDepth].x = self.template[self.beingDraggedID][self.beingDraggedDepth].x + dx
    self.template[self.beingDraggedID][self.beingDraggedDepth].y = self.template[self.beingDraggedID][self.beingDraggedDepth].y + dy
  end
end

function GUI._alignElement(_drawingTemplate, i, template)
  if template.alignment then -- These values are being baked into the offset functions by VALUE not by REFERENCE (since the reference to template is forever lost after constructing the drawing templates!) This means that if AlignmentType.FIXED is implemeneted, we will need to use unbaked values in some sense (?)
    if template.alignment == GUI.Alignment.TOP then
      _drawingTemplate[i].x_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].width / 2 - _drawingTemplate[i].width / 2 end
      if template.alignmentOptions then
        GUI._errorCheck{
          condition = not template.alignmentOptions.top,
          message = 'field \'top\' is required in \'alignmentOptions\'!'
        }
        _drawingTemplate[i].y_offset = function() return template.alignmentOptions.top end
      else
        _drawingTemplate[i].y_offset = GUI.return0
      end
    elseif template.alignment == GUI.Alignment.TOP_LEFT then
      if template.alignmentOptions then
        GUI._errorCheck{
          condition = not (template.alignmentOptions.top and template.alignmentOptions.left),
          message = 'fields \'top\' or \'left\' are required in \'alignmentOptions\'!'
        }
        _drawingTemplate[i].x_offset = function() return template.alignmentOptions.left end
        _drawingTemplate[i].y_offset = function() return template.alignmentOptions.top end
      else
        _drawingTemplate[i].x_offset = GUI.return0
        _drawingTemplate[i].y_offset = GUI.return0
      end
    elseif template.alignment == GUI.Alignment.LEFT then
      _drawingTemplate[i].y_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].height / 2 - _drawingTemplate[i].height / 2 end
      if template.alignmentOptions then
        GUI._errorCheck{
          condition = not template.alignmentOptions.left,
          message = 'field \'left\' is required in \'alignmentOptions\'!'
        }
        _drawingTemplate[i].x_offset = function() return template.alignmentOptions.left end
      else
        _drawingTemplate[i].x_offset = GUI.return0
      end
    elseif template.alignment == GUI.Alignment.BOTTOM_LEFT then
      if template.alignmentOptions then
        GUI._errorCheck{
          condition = not (template.alignmentOptions.bottom and template.alignmentOptions.left),
          message = 'field \'bottom\' or \'left\' are required in \'alignmentOptions\'!'
        }
        _drawingTemplate[i].x_offset = function() return template.alignmentOptions.left end
        _drawingTemplate[i].y_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].height - (_drawingTemplate[i].height + template.alignmentOptions.bottom) end
      else
        _drawingTemplate[i].x_offset = GUI._return0
        _drawingTemplate[i].y_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].height - _drawingTemplate[i].height end
      end
    elseif template.alignment == GUI.Alignment.BOTTOM then
      _drawingTemplate[i].x_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].width / 2 - _drawingTemplate[i].width / 2 end
      if template.alignmentOptions then
        GUI._errorCheck{
          condition = not template.alignmentOptions.bottom,
          message = 'field \'bottom\' is required in \'alignmentOptions\'!'
        }
        _drawingTemplate[i].y_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].height - (_drawingTemplate[i].height + template.alignmentOptions.bottom) end
      else
        _drawingTemplate[i].y_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].height - _drawingTemplate[i].height end
      end
    elseif template.alignment == GUI.Alignment.BOTTOM_RIGHT then
      if template.alignmentOptions then
        GUI._errorCheck{
          condition = not (template.alignmentOptions.bottom and template.alignmentOptions.right),
          message = 'fields \'bottom \' and \'right\' are required in \'alignmentOptions\'!'
        }
        _drawingTemplate[i].x_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].width - (_drawingTemplate[i].width + template.alignmentOptions.right) end
        _drawingTemplate[i].y_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].height - (_drawingTemplate[i].height + template.alignmentOptions.bottom) end
      else
        _drawingTemplate[i].x_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].width - _drawingTemplate[i].width end
        _drawingTemplate[i].y_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].height - _drawingTemplate[i].height end
      end
    elseif template.alignment == GUI.Alignment.RIGHT then
      _drawingTemplate[i].y_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].height / 2 - _drawingTemplate[i].height / 2 end
      if template.alignmentOptions then
        GUI._errorCheck{
          condition = not template.alignmentOptions.right,
          message = 'field \'right\' is required in \'alignmentOptions\'!'
        }
        _drawingTemplate[i].x_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].width - (_drawingTemplate[i].width + template.alignmentOptions.right) end
      else
        _drawingTemplate[i].x_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].width - _drawingTemplate[i].width end
      end
    elseif template.alignment == GUI.Alignment.TOP_RIGHT then
      if template.alignmentOptions then
        GUI._errorCheck{
          condition = not (template.alignmentOptions.top and template.alignmentOptions.right),
          message = 'fields \'top\' and \'right\' is required in \'alignmentOptions\'!'
        }
        _drawingTemplate[i].x_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].width - (_drawingTemplate[i].width + template.alignmentOptions.right) end
        _drawingTemplate[i].y_offset = function() return template.alignmentOptions.top end
      else
        _drawingTemplate[i].x_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].width - _drawingTemplate[i].width end
        _drawingTemplate[i].y_offset = GUI._return0
      end
    end
  else -- CENTER (default)
    _drawingTemplate[i].x_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].width / 2 - _drawingTemplate[i].width / 2 end
    _drawingTemplate[i].y_offset = function() return _drawingTemplate[_drawingTemplate[i].parent].height / 2 - _drawingTemplate[i].height / 2 end
  end
end

function GUI._gesturizeElement(self, id, depth, _drawingTemplate, i, template)
  if template.draggable then
    self._hb[id]:register{
      id = id .. ' ' .. depth,
      object = _drawingTemplate[i],
    }
    _drawingTemplate[i].onEnter = function() 
      self._dragReadyDepth[id] = depth
    end -- prime it for dragging
    _drawingTemplate[i].onDragBegin = template.onDragBegin or function() end
    _drawingTemplate[i].onExit = function() 
      self._dragReadyDepth[id] = nil 
    end -- de-prime
    _drawingTemplate[i].onDragEnd = template.onDragEnd or function () end
  end
  
end

function GUI._drawFunctionByTemplate(template)
  if template.base == GUI.Base.RECTANGLE then
    return function(self) love.graphics.rectangle(self.fill or 'line', self.x, self.y, self.width or 100, self.height or 100) end
    -- return function(self) print('love.graphics.rectangle(' .. (self.fill or '\'fill\'') .. ', ' .. self.x  .. ', '.. self.y .. ', ' .. (self.width or 100) .. ', ' .. (self.height or 100) .. ')') end
  else
    -- return function(x, y) love.graphics.draw(nil, x, y) end
  end
end

function GUI._return0()
  return 0
end

function GUI._errorCheck(params)  -- {condition, message} -- if condition is false, deliver error
  if params.condition then
    error('gui_error: ' .. params.message)
  end
end

function GUI._retrieveByID(self, id)
  return self.template[id]
end

return GUI





------------------
-- LATER THINGS --
------------------

  -- if template['child'] or template['children'] then -- consider 'children' later

  -- end