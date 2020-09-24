-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

-- Require libraries
Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

-- Require utility code
require 'src/constants'
require 'src/StateMachine'
require 'src/Util'

-- Require state code
require 'src/states/BaseState'
require 'src/states/GameOverState'
require 'src/states/OfferState'
require 'src/states/PlayState'
require 'src/states/ResultState'
require 'src/states/ShuffleState'
require 'src/states/StartState'

-- Require object code
require 'src/Case'
require 'src/Banker'
require 'src/Scoreboard'

-- Require audio
gameAudio = {
    -- Sound effects generated in Bfxr
    ['cursor'] = love.audio.newSource('sounds/cursor.wav'),
    ['select'] = love.audio.newSource('sounds/select.wav'),
    ['good'] = love.audio.newSource('sounds/good.wav'),
    ['bad'] = love.audio.newSource('sounds/bad.wav'),
    ['deal'] = love.audio.newSource('sounds/deal.wav'),
    ['nodeal'] = love.audio.newSource('sounds/nodeal.wav'),

    -- Music by Kevin MacLeod (incompetech.com)
    -- Licensed under Creative Commons: By Attribution 4.0 License
    -- http://creativecommons.org/licenses/by/4.0/

    -- Floating Cities
    ['think'] = love.audio.newSource('sounds/think.mp3'),
    -- Prelude and Action
    ['action'] = love.audio.newSource('sounds/action.mp3'),
    -- Son of a Rocket
    ['funky'] = love.audio.newSource('sounds/funky.mp3'),
    -- The Descent
    ['suspense'] = love.audio.newSource('sounds/suspense.mp3'),
    -- Inspired
    ['lounge'] = love.audio.newSource('sounds/lounge.mp3')
}

-- Require textures
gameTex = {
    -- Textures created by yours truly
    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['case'] = love.graphics.newImage('graphics/case.png'),
    ['score'] = love.graphics.newImage('graphics/score.png'),
    ['cat'] = love.graphics.newImage('graphics/cat.png')
}

-- Require quad frames
gameFrames = {
    ['case'] = GenerateQuads(gameTex['case'], TILE_SIZE, TILE_SIZE),
    ['score'] = GenerateQuads(gameTex['score'], TILE_SIZE, TILE_SIZE),
    ['cat'] = GenerateQuads(gameTex['cat'], TILE_SIZE*2, TILE_SIZE*2)
}

-- Require fonts
gameFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
    ['title'] = love.graphics.newFont('fonts/fipps.otf', 32)
}
