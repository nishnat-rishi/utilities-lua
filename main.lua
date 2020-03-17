Timer = require('Timer')
Animation = require('Animation')
Curves = require('Curves')
Hitbox = require('Hitbox')

function createSmallBox(params)
  return {
    x = params.x,
    y = params.y,
    width = params.width,
    height = params.height,
    draw = function(self)
      love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    end,
    onEnter = function(self) message = 'Entered!' end,
    onExit = function(self) message = 'Exited!' end,
  }
end

function love.load()
  t = Timer.create()
  a = Animation.createController()
  h = Hitbox.createController()
  smallBox = createSmallBox{x=100, y = 100, width = 100, height = 100}

  message = 'Hi!'

  t:register {
    id = 1, 
    duration = 2, -- in seconds
    callback = function() a:toggle(1) end,
    periodic = true
  }
  
  a:register {
    id = 1,
    duration = 0.6,
    curve = Curves.easeIn,
    reversible = true,
    continuous = true,
    tweener = {object=smallBox, index='x', initial=100, final=200},
  }

  h:register{ -- *4
    id = 1,
    object = smallBox
  }
  
end

function love.update(dt)
  t:update(dt)
  a:update()
  h:update(love.mouse.getX(), love.mouse.getY()) -- *1 *3
end

function love.draw(dt)
  smallBox:draw()
  love.graphics.print(message, 400, 200)
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