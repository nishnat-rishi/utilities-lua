Timer = require('Timer')
Animation = require('Animation')
Curves = require('Curves')

function love.load()
  t = Timer.create()
  a = Animation.createController()
  x = {100} --  wrap all 'animatable' variables into a table
  t:register {
    id = 1, 
    duration = 2, -- in seconds
    callback = function() a:play(1) end,
    periodic = true
  }
  a:register {
    id = 1,
    duration = 1.2,
    curve = Curves.easeIn,
    reversible = true,
    tweener = {x, 100, 200},
  }
  
end

function love.update(dt)
  t:update(dt)
  a:update(dt)
end

function love.draw(dt)
  love.graphics.rectangle('fill', x[1], 100, 100, 100)
end