-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

-- Credits:
-- Kevin MacLeod (Incompetech) for music assets under Creative Commons (BY 4.0).
-- Authors of the Push, Hump, and Knife libraries used in the project.
-- Colton Ogden for making the GD50 course!

-- Set nearest neighbor filter
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Import dependencies
require 'src/Dependencies'

function love.load()
    -- Set window title
    love.window.setTitle('Deal50')

    -- Seed RNG based on current system time
    math.randomseed(os.time())

    -- Start screen with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true,
        canvas = true
    })

    -- Create state machine
    gameStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['shuffle'] = function() return ShuffleState() end,
        ['play'] = function() return PlayState() end,
        ['offer'] = function() return OfferState() end,
        ['result'] = function() return ResultState() end,
        ['game-over'] = function() return GameOverState() end,
    }

    -- Control variables for background.
    bg_R, bg_G, bg_B = BGDEFAULT_R, BGDEFAULT_G, BGDEFAULT_B

    -- Go to start state
    gameStateMachine:change('start')

    -- Start table for keyboard input
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

-- Update the color of the background
-- based on given RGB values
function UpdateBG(R, G, B)
    bg_R, bg_G, bg_B = R, G, B
end

-- Update function will update state and reset keys
-- pressed list to prepare for the next frame.
function love.update(dt)
    gameStateMachine:update(dt)
    love.keyboard.keysPressed = {}
end

function love.draw()
    -- Start push graphics
    push:start()

    -- Set color for background
    love.graphics.setColor(bg_R, bg_G, bg_B, 255)
    -- Draw background
    love.graphics.draw(
        -- Use background texture
        gameTex['background'],
        -- X and Y at 0, with no rotation
        0, 0, 0,
        -- Width and height set to fill up the whole screen
        VIRTUAL_WIDTH / (gameTex['background']:getWidth() - 1),
        VIRTUAL_HEIGHT / (gameTex['background']:getHeight() - 1)
    )

    -- Render state objects
    gameStateMachine:render()

    -- Finish push for current frame
    push:finish()
end