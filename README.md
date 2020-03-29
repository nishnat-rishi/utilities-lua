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

Timer.lua, Hitbox.lua and Animation.lua follow a standard. Instances of these objects are controllers which maintain a registry of multiple individual entities (i.e. timers, hitboxes, animations). This allows users to maintain separate controllers for similar sets of objects (ex. A single hitbox controller maintaining hitboxes of 7 card objects representing a single hand in a card game).

Except Timer.lua, no other module manages memory automatically. One has to manually deregister hitboxes and animations to 'delete' them (i.e. enable them to be garbage collected). This decision has been taken to ensure no accidental interactions happen (i.e. trying to play a deregistered animation), and to make sure control of the cleaning discipline ultimately lies with the developer.

Animation.lua has fast runtime performance because it calculates all intermediate states on registration. This means that the system merely retrieves the intermediate states during drawing (as opposed to calculating them).