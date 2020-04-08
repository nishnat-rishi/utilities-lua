# Lua Game Development Utilities

## Animation.lua
- Register animations to object variables.
- Play, pause, toggle, reset animations at any point. 
- Safe registration, deregistration.
- Fast runtime performance.

## Hitbox.lua
- Register object hitboxes. 
- onEnter, onExit callbacks.
- Safe registration, deregistration.
- Check for collision on change or on every frame.

## Timer.lua
- Register timers.
- Attach callbacks upon end of timer.
- Safe registration, deregistration.

## GUI.lua (BARELY WORKING PROTOTYPE)
- Construct GUI elements, "Flutter" style.

## Curves.lua
Helper module for Animation.lua.

# Details

Timer.lua, Hitbox.lua and Animation.lua follow a standard. Instances of these classes are controllers which maintain a registry of multiple individual entities (i.e. timers, hitboxes, animations). This allows users to maintain separate controllers for similar sets of objects (ex. A single hitbox controller maintaining hitboxes of 7 card objects representing a single hand in a card game).

Except Timer.lua, no other module manages memory automatically. One has to manually deregister hitboxes and animations to 'delete' them (i.e. enable them to be garbage collected). This decision has been taken to ensure no accidental interactions happen (i.e. trying to play a deregistered animation), and to make sure control of the cleaning discipline ultimately lies with the developer.

Animation.lua has fast runtime performance because it calculates all intermediate states on registration. This means that the system merely retrieves the intermediate states during drawing (as opposed to calculating them).

# Barebones Demonstration

## Animation-Timer-Hitbox

 ```lua
smallBox = createSmallBox{ -- demo box
    x=100, 
    y = 100, 
    width = 100, 
    height = 100, 
    onEnter = function(self) message = 'Entered!' end,
    onExit = function(self) message = 'Exited!' end,
  }

 a:register { -- animation controller
    id = 1,
    duration = 0.6, -- seconds
    curve = Curves.easeIn,
    reversible = true,
    continuous = true,
    tweener = {object=smallBox, index='x', initial=100, final=200},
  }

  t:register { -- timer controller
    id = 1, 
    duration = 2, -- seconds
    callback = function() a:toggle(1) end,
    periodic = true
  }

  h:register{ -- hitbox controller
    id = 1,
    object = smallBox
  }
  ```

![animation_timer_hitbox.gif](https://s5.gifyu.com/images/ath.gif "Animation Timer Hitbox Demo")

## GUI Construction

```lua
gui:construct('casual box', {x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2}, {
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
```
![gui.gif](https://s5.gifyu.com/images/GUI4ee40a199c70eefb.gif "GUI Demo")
