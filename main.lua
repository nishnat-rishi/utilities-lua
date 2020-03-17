Timer = require('Timer')
Animation = require('Animation')
Curves = require('Curves')

function love.load()
  t = Timer.create()
  a = Animation.createController()

  x = {100} --  wrap all 'animatable' variables in a table

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
    tweener = {x, 100, 200},
  }
  
end

function love.update(dt)
  t:update(dt)
  a:update()
end

function love.draw(dt)
  love.graphics.rectangle('fill', x[1], 100, 100, 100)
end

function love.keypressed(key)
  if key == 'space' then
    a:toggle(1)
  end
  if key == 'd' then
    a:deregister(1)
  end
end