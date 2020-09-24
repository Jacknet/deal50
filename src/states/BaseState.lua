-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

-- Base class for all game states

BaseState = Class{}

function BaseState:init() end
function BaseState:enter() end
function BaseState:exit() end
function BaseState:update(dt) end
function BaseState:render() end