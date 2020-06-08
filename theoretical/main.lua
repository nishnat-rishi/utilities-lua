Timer = require('Timer')
Animation = require('Animation')
Curves = require('Curves')
Hitbox = require('Hitbox')
GUI = require('GUI')

function createSmallBox(params)
  return {
    x = params.x,
    y = params.y,
    width = params.width,
    height = params.height,
    draw = function(self)
      love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end,
    onEnter = params.onEnter,
    onExit = params.onExit,
  }
end

function love.load()
  t = Timer.create()
  a = Animation.createController()
  h = Hitbox.createController()
  g = GUI.create{
    windowDimensions = {width = love.graphics.getWidth(), height = love.graphics.getHeight()}
  }
  smallBox = createSmallBox{
    x=100, 
    y = 100, 
    width = 100, 
    height = 100, 
    onEnter = function(self) message = 'Entered!' end,
    onExit = function(self) message = 'Exited!' end,
  }

  message = 'Hi!'
  
  a:register {
    id = 1,
    duration = 0.6, -- seconds
    curve = Curves.easeIn,
    reversible = true,
    continuous = true,
    tweener = {object=smallBox, index='x', initial=100, final=200},
  }

  t:register {
    id = 1, 
    duration = 2, -- seconds
    callback = function() a:toggle(1) end,
    periodic = true
  }

  h:register{ -- *4
    id = 1,
    object = smallBox
  }

  g:construct('casual box', {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}, {
    base = GUI.Base.RECTANGLE,
    width = 100,
    height = 100,
    draggable = true,
    onDragBegin = function () message = 'Drag begun!' end,
    onDragEnd = function() message = 'Drag ended!' end,
    child = {
      base = GUI.Base.RECTANGLE,
      width = 50,
      height = 50,
      alignment = GUI.Alignment.TOP_RIGHT,
      alignmentOptions = {top = 50, right = 50},
      child = {
        base = GUI.Base.RECTANGLE,
        width = 25,
        height = 25,
      }
    }
  })
  
end

function love.update(dt)
  t:update(dt)
  a:update()
  h:update(love.mouse.getX(), love.mouse.getY()) -- *1 *3
  g:update('casual box')
end

function love.draw(dt)
  smallBox:draw()
  love.graphics.print(message, 400, 200)
  g:draw('casual box')
end

function love.keypressed(key)
  if key == 'space' then
    a:toggle(1)
  end
  if key == 'd' then
    a:deregister(1)
  end
end

function love.mousemoved(x, y, dx, dy, istouch)
  -- h:update(x, y) -- *2
  g:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
  g:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
  g:mousereleased(x, y, button, istouch, presses)
end

--------------------
----- COMMENTS -----
--------------------

--[[ 

*1: \/
*2: \/
*3: Toggling between these two lines would result in very different 
    behaviours. Also, *1, uses more resources than *2 (since it's called every
    frame as opposed to being called only when the mouse moves.)
    
*4: Attach a timer so that collision detection happens every 0.1 seconds instead
    of 60 times a second! (Potentially bad idea!)

--]]