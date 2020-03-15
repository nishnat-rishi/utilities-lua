# Lua Game Development Utilities
## Animation.lua
Allows users to register and perform animations. It is supposedly a fast implementation since currently no state calculations are performed during runtime. All inbetween states are calculated on registration and only retrieval happens during runtime.

Users can play, pause, reset animations at any point. Animations can be reversible and continuous.

## Timer.lua
Allows users to register timers and attach callbacks. Newly added support for runtime registration.

## Curves.lua
Helper module for Animation.lua.
