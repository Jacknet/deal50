-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

ShuffleState = Class{__includes = BaseState}

function ShuffleState:init()
    -- Play shuffle music and set it to loop
    gameAudio['lounge']:setLooping(true)
    gameAudio['lounge']:play()

    -- Variables to determine if swapping is complete
    self.haltPresses = true

    -- Variables to store prompt text and its alpha
    self.promptText = "Good Luck!"
    self.promptAlpha = 0

    -- Several check variables for pulling off shuffle anim
    self.shuffleOn = false
    self.shufflePromptSet = false
    self.shuffleAnimCount = 0
    self.shuffleAnimFlip = 0
    self.shuffleMax = 100

    -- Fade in prompt text as we enter the state.
    Timer.tween(1, {
        [self] = {promptAlpha = 255}
    })

    -- Reveal cases after 1 second since enter
    Timer.after(1, function()
        for i = 1, #CASE_VALUES do
            self.cases[i]:appearCase()
        end
    end)

    -- After 3 seconds since enter, SHUFFLE!
    Timer.after(3, function()
        self.promptText = "Shuffling..."
        self.shuffleOn = true
    end)
end

function ShuffleState:enter(params)
    -- Grab the cases that were passed from
    -- the prior state and store them for use here.
    self.cases = params.cases or {}
end

function ShuffleState:update(dt)
    -- Press escape at any time to quit, regardless
    -- if haltPresses is on during transitions.
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- With this, I could avoid a Timer.after eyesore!
    -- Believe me, you do not wanna see how the code after where
    -- the "Shuffling..." text is set looked like... Yikes!
    -- If shuffle's on and we have not reached our shuffleMax yet
    if self.shuffleOn and (self.shuffleAnimCount < self.shuffleMax) then
        -- Turn off shuffle one-shot and set tween flipper back to 0
        self.shuffleOn = false
        self.shuffleAnimFlip = 0

        -- Do a shuffle!
        self:doShuffle()

        -- Tween animation counter, then turn shuffle back on afterward
        Timer.tween(0.15, {
            [self] = {shuffleAnimFlip = 1}
        }):finish(function()
            self.shuffleOn = true
        end)

        -- Increment animation count back to 1
        self.shuffleAnimCount = self.shuffleAnimCount + 1
    -- If we have reached the maximum and if we have not set the prompt yet
    elseif (self.shuffleAnimCount == self.shuffleMax) and not self.shufflePromptSet then
        -- Set prompt set to true
        self.shufflePromptSet = true

        -- After 1 second, set prompt, display case keys,
        -- and give control back to player.
        Timer.after(1, function()
            self.promptText = "Pick a Container"
            for i = 1, #CASE_VALUES do
                self.cases[i].displayKey = true
            end
            self.haltPresses = false
        end)
    end

    -- Accept input once halt flag is released
    if not self.haltPresses then
        -- Go through every case
        for i = 1, #CASE_VALUES do
            -- If we chose a case and double-checking halt presses is not on
            if love.keyboard.wasPressed(self.cases[i].keyButton)
            and not self.haltPresses then
                -- Halt any presses as we picked a case
                -- and we move on to the play state
                self.haltPresses = true
                -- Say what case the player chose
                self.promptText = "Your Container Is " .. string.upper(self.cases[i].keyButton)
                -- Play a sound effect confirming our choice
                gameAudio['good']:stop()
                gameAudio['good']:play()
                -- Tween case to the bottom right corner
                Timer.tween(1, {
                    [self.cases[i]] = {
                        x = VIRTUAL_WIDTH - (TILE_SIZE*3),
                        y = VIRTUAL_HEIGHT - (TILE_SIZE*3)
                    }
                })
                -- Set that this case is ours
                self.cases[i].chosenCase = true

                -- Fade out text after 3 seconds then move to next state
                Timer.after(3, function()
                    Timer.tween(1, {
                        [self] = {promptAlpha = 0}
                    }):finish(function()
                        -- Move to the play state, sending the cases
                        gameAudio['lounge']:stop()
                        gameStateMachine:change('play', {
                            cases = self.cases
                        })
                    end)
                end)
            end
        end
    end

    -- Update timer
    Timer.update(dt)
end

function ShuffleState:render()
    -- Draw cases
    for i = 1, #CASE_VALUES do
        self.cases[i]:render()
    end

    -- Print the prompts
    self:printPrompt(self.promptText, self.promptAlpha)
end

-- Shuffle a case!
function ShuffleState:doShuffle()
    -- Pick two random case numbers
    local case1 = math.random(1, #CASE_VALUES)
    local case2 = math.random(1, #CASE_VALUES)

    -- If both case numbers are the same, pick a number for the
    -- the second case number is not the number for the first
    if case1 == case2 then
        if case1 < (#CASE_VALUES / 2) then
            case2 = math.random(case1 + 1, #CASE_VALUES)
        else
            case2 = math.random(1, case1 - 1)
        end
    end

    -- Temporarily store the values of the cases for swapping
    local x1, x2 = self.cases[case1].x, self.cases[case2].x
    local y1, y2 = self.cases[case1].y, self.cases[case2].y
    local keyButton1, keyButton2 = self.cases[case1].keyButton, self.cases[case2].keyButton

    -- Swap keys
    self.cases[case1].keyButton, self.cases[case2].keyButton = keyButton2, keyButton1
    -- Tween the swap
    Timer.tween(0.15, {
        [self.cases[case1]] = {x = x2, y = y2},
        [self.cases[case2]] = {x = x1, y = y1}
    })
end

function ShuffleState:printPrompt(text, alpha)
    -- Set prompt font
    love.graphics.setFont(gameFonts['medium'])

    -- Set shadow color
    love.graphics.setColor(0, 0, 0, alpha / 2)
    -- Print enter prompt shadow
    love.graphics.printf(text, 1, VIRTUAL_HEIGHT / 12 + 1, VIRTUAL_WIDTH, 'center')

    -- Set the color for the prompt
    love.graphics.setColor(255, 255, 255, alpha)
    -- Print the prompt
    -- The prompt is shifted by one pixel to the
    -- left to avoid nearest neighbor artifacting.
    love.graphics.printf(text, -1, VIRTUAL_HEIGHT / 12 - 1, VIRTUAL_WIDTH, 'center')
end
