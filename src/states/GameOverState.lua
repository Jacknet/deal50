-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

GameOverState = Class{__includes = BaseState}

function GameOverState:init()
    -- Set color to yellow
    UpdateBG(255, 128, 0)

    -- Flag to halt input during animations
    self.haltPresses = true

    -- Variable to store the final score
    self.finalScore = 0

    -- Alpha variable for when we exit the state
    self.fadeAlpha = 0

    -- Alpha variable for fading text
    self.textAlpha = 0
end

function GameOverState:enter(params)
    -- Grab winning score
    self.finalScore = params.finalScore or 0

    -- Tween text fade
    Timer.tween(1, {
        [self] = {textAlpha = 255}
    }):finish(function()
        -- Give control back to player
        self.haltPresses = false
    end)
end

function GameOverState:update(dt)
    -- Press escape at any time to quit, regardless
    -- if haltPresses is on during transitions.
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if not self.haltPresses then
        if love.keyboard.wasPressed('space') then
            -- Play sound effect for feedback
            gameAudio['select']:stop()
            gameAudio['select']:play()
            -- Halt presses
            self.haltPresses = true     
            -- Fade to start
            Timer.tween(1, {
                [self] = {fadeAlpha = 255}
            }):finish(function()
                -- Stop action music
                gameAudio['action']:stop()
                -- Reset game
                gameStateMachine:change('start')
            end)
        end
    end

    -- Update timer
    Timer.update(dt)
end

function GameOverState:render()
    -- Print Game Over text
    self:printTitle("GAME OVER", self.textAlpha)

    -- Print the player's score
    self:printScore(self.finalScore, self.textAlpha)

    -- Set subprompt font
    love.graphics.setFont(gameFonts['medium'])
    -- Print subprompt
    love.graphics.setColor(0, 0, 0, self.textAlpha / 2)
    love.graphics.printf("Press SPACE to play again!", 2, VIRTUAL_HEIGHT / 1.25 + 2, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, self.textAlpha)
    love.graphics.printf("Press SPACE to play again!", 0, VIRTUAL_HEIGHT / 1.25, VIRTUAL_WIDTH, 'center')

    -- Rectangle that fills the whole screen,
    -- providing a transition effect using a
    -- variable alpha value.
    love.graphics.setColor(255, 255, 255, self.fadeAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function GameOverState:printTitle(text, alpha)
    -- Set game over font
    love.graphics.setFont(gameFonts['title'])
    -- Print shadow
    love.graphics.setColor(0, 0, 0, alpha / 2)
    love.graphics.printf(text, 3, VIRTUAL_HEIGHT / 8 + 3, VIRTUAL_WIDTH, 'center')
    -- Print text
    love.graphics.setColor(255, 255, 0, alpha)
    love.graphics.printf(text, 0, VIRTUAL_HEIGHT / 8, VIRTUAL_WIDTH, 'center')
end

function GameOverState:printScore(score, alpha)
    -- Set score font
    love.graphics.setFont(gameFonts['large'])
    -- Print prompt shadow
    love.graphics.setColor(0, 0, 0, alpha / 2)
    love.graphics.printf("Your Score:", 3, VIRTUAL_HEIGHT / 2 - 29, VIRTUAL_WIDTH, 'center')
    -- Print prompt
    love.graphics.setColor(255, 255, 255, alpha)
    love.graphics.printf("Your Score:", -1, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')
    -- Print score shadow
    love.graphics.setColor(0, 0, 0, 255 / 2)
    love.graphics.printf(score, 5, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    -- Print score itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf(score, 1, VIRTUAL_HEIGHT / 2 - 3, VIRTUAL_WIDTH, 'center')
end