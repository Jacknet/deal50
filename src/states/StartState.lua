-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

StartState = Class{__includes = BaseState}

function StartState:init()
    -- Play menu music and set it to loop
    gameAudio['funky']:setLooping(true)
    gameAudio['funky']:play()

    -- Set color to default background
    UpdateBG(BGDEFAULT_R, BGDEFAULT_G, BGDEFAULT_B)

    -- Boolean check to stop enter presses during
    -- transitions. As we fade out, we start with true.
    self.haltPresses = true

    -- Array that will be holding the cases
    self.cases = {}

    -- Instantiate the cases
    for i = 1, #CASE_VALUES do
        if i <= #KEYROW_ONE then
            table.insert(self.cases, Case({
                pointValue = CASE_VALUES[i],
                keyButton = KEYROW_ONE[i],
                x = 40 * (i + 0.5),
                y = 60
            }))
        elseif i <= (#KEYROW_ONE + #KEYROW_TWO) then
            table.insert(self.cases, Case({
                pointValue = CASE_VALUES[i],
                keyButton = KEYROW_TWO[i - #KEYROW_ONE],
                x = 40 * (i - 9),
                y = 100
            }))
        else
            table.insert(self.cases, Case({
                pointValue = CASE_VALUES[i],
                keyButton = KEYROW_THREE[i - (#KEYROW_ONE + #KEYROW_TWO)],
                x = 40 * (i - 17),
                y = 140
            }))
        end
    end

    -- Variable that will store blue color value
    -- for pulsating title screen
    self.pulseColor = 0

    -- Flip flag for title screen pulse to
    -- ensure Timer does not get flooded.
    self.pulseEase = true
    
    -- Alpha variables for when we enter and exit the state.
    -- As we fade out, we start with no transparency on the
    -- box fade. 
    self.fadeAlpha = 255
    self.textAlpha = 255

    -- Fade out as we enter the state, by lowering
    -- alpha with a tween, then enabling presses after.
    Timer.tween(1, {
        [self] = {fadeAlpha = 0}
    }):finish(function()
        self.haltPresses = false
    end)
end

function StartState:update(dt)
    -- Press escape at any time to quit, regardless
    -- if haltPresses is on during transitions.
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- Move to next state when Space is pressed.
    -- Only accept the presses if we're
    -- not transitioning.
    if love.keyboard.wasPressed('space') and not self.haltPresses then
        -- Disable any further button presses
        self.haltPresses = true

        -- Play sound effect for feedback
        gameAudio['select']:stop()
        gameAudio['select']:play()

        -- Fade out title screen
        Timer.tween(1, {
            [self] = {textAlpha = 0}
        }):finish(function()
            -- Stop current music
            gameAudio['funky']:stop()
            -- Change to shuffle state, passing cases
            gameStateMachine:change('shuffle', {
               cases = self.cases
            })
        end)
    end

    -- Pulsate title screen repeatedly
    if self.pulseEase then
        self.pulseEase = false
        Timer.tween(1, {
            [self] = {pulseColor = 255}
        }):finish(function()
            Timer.tween(1, {
                [self] = {pulseColor = 0}
            }):finish(function()
                self.pulseEase = true
            end)
        end)
    end

    -- Update timer
    Timer.update(dt)
end

function StartState:render()
    -- Draw cases
    for i = 1, #CASE_VALUES do
        self.cases[i]:render()
    end

    -- Print the title screen
    self:printTitle("Deal50", self.textAlpha, self.pulseColor)

    -- Print the prompts
    self:printPrompt("Press SPACE to Play!", self.textAlpha)
    self:printSubPrompt("ESC to quit at any time", self.textAlpha)

    -- Rectangle that fills the whole screen,
    -- providing a transition effect using a
    -- variable alpha value.
    love.graphics.setColor(255, 255, 255, self.fadeAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

-- To make it easier to distinguish certain
-- title screen elements, they have been
-- made into their own functions for render.

function StartState:printTitle(title, alpha, pulse)
    -- Set title font
    love.graphics.setFont(gameFonts['title'])

    -- Set shadow color
    love.graphics.setColor(0, 0, 0, alpha / 2)
    -- Print shadow text
    love.graphics.printf(title, 3, VIRTUAL_HEIGHT / 8 + 3, VIRTUAL_WIDTH, 'center')

    -- Set the color for the title
    love.graphics.setColor(255, 255, pulse, alpha)
    -- Print the text
    love.graphics.printf(title, 0, VIRTUAL_HEIGHT / 8, VIRTUAL_WIDTH, 'center')
end

function StartState:printPrompt(text, alpha)
    -- Set prompt font
    love.graphics.setFont(gameFonts['large'])

    -- Set shadow color
    love.graphics.setColor(0, 0, 0, alpha / 2)
    -- Print prompt shadow
    love.graphics.printf(text, 3, VIRTUAL_HEIGHT / 2 + 3, VIRTUAL_WIDTH, 'center')

    -- Set the color for the prompt
    love.graphics.setColor(255, 255, 255, alpha)
    -- Print the prompt
    -- The prompt is shifted by one pixel to the
    -- left to avoid nearest neighbor artifacting.
    love.graphics.printf(text, -1, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
end

function StartState:printSubPrompt(text, alpha)
    -- Set subprompt font
    love.graphics.setFont(gameFonts['medium'])

    -- Set shadow color
    love.graphics.setColor(0, 0, 0, alpha / 2)
    -- Print prompt shadow
    love.graphics.printf(text, 2, VIRTUAL_HEIGHT / 1.25 + 2, VIRTUAL_WIDTH, 'center')

    -- Set the color for the subprompt
    love.graphics.setColor(255, 255, 255, alpha)
    -- Print the prompt
    love.graphics.printf(text, 0, VIRTUAL_HEIGHT / 1.25, VIRTUAL_WIDTH, 'center')
end
