-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

PlayState = Class{__includes = BaseState}

function PlayState:init()
    -- Play shuffle music and set it to loop
    gameAudio['think']:setLooping(true)
    gameAudio['think']:play()

    -- Set color to default background
    UpdateBG(BGDEFAULT_R, BGDEFAULT_G, BGDEFAULT_B)

    -- Variables to determine if animations are complete
    self.haltPresses = true

    -- Variable to hold the cases
    self.cases = {}

    -- Store score boards to display
    self.scoreBoard = {}

    -- Variable to store the number of cases
    -- left and how many we opened.
    self.casesToOpen = 0
    self.casesOpened = 0

    -- Variables to store initial prompt text and its alpha
    self.promptText = ""
    self.promptAlpha = 0

    -- Alpha variable for when we enter and exit the state. 
    self.fadeAlpha = 0
end

function PlayState:enter(params)
    -- Grab the cases that were passed from
    -- the prior state and store them for use here.
    self.cases = params.cases or {}

    -- Grab cases to open. Default 6
    self.casesToOpen = params.casesToOpen or 6

    -- Reset casesOpened
    self.casesOpened = 0

    -- Set prompt text
    self.promptText = "Open " .. self.casesToOpen .. " Container"
    if not (params.casesToOpen == 1) then
        self.promptText = self.promptText .. "s"
    end

    -- Instantiate scoreboard
    for i = 1, #CASE_VALUES do
        if i <= #CASE_VALUES/2 then
            table.insert(self.scoreBoard, Scoreboard({
                refCase = self.cases[i] or Case(),
                x = (TILE_SIZE*2) * (i),
                y = VIRTUAL_HEIGHT - (TILE_SIZE*5)
            }))
        else
            table.insert(self.scoreBoard, Scoreboard({
                refCase = self.cases[i] or Case(),
                x = (TILE_SIZE*2) * ((i-(#CASE_VALUES/2))),
                y = VIRTUAL_HEIGHT - (TILE_SIZE*3)
            }))
        end
    end

    -- The banker state should return 255 for fade alpha.
    self.fadeAlpha = params.fadeAlpha or 0

    -- Fade out as we enter the state if coming from banker.
    if self.fadeAlpha > 0 then
        -- Immediately reveal text and board if coming from banker and
        -- make sure control is not given back yet to player.
        for i = 1, #CASE_VALUES do
            self.scoreBoard[i].alphaTransition = 255
        end
        self.promptAlpha = 255
        self.haltPresses = true

        -- If a case is open after the state change,
        -- hide it as it is no longer needed in play.
        for i = 1, #CASE_VALUES do
            if self.cases[i].isOpened then
                self.cases[i].toHide = true
            end
        end

        -- Run animation then release key halt flag.
        Timer.tween(1, {
            [self] = {fadeAlpha = 0}
        }):finish(function() self.haltPresses = false end)
    else
        -- If we're coming from some other state,
        -- fade in prompt text and score board
        -- as we enter the state and give back
        -- control to the player.
        for i = 1, #CASE_VALUES do
            Timer.tween(1, {
                [self.scoreBoard[i]] = {alphaTransition = 255}
            })
        end
        Timer.tween(1, {
            [self] = {promptAlpha = 255},
        }):finish(function()
            self.haltPresses = false
        end)
    end
end

function PlayState:update(dt)
    -- Press escape at any time to quit, regardless
    -- if haltPresses is on during transitions.
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- Accept input once halt flag is released
    if not self.haltPresses then
        -- If we chose a case and it has not been
        -- opened yet and is not our chosen case
        -- AND making sure halt presses is not on
        -- AND we have not reached our limit
        for i = 1, #CASE_VALUES do
            if love.keyboard.wasPressed(self.cases[i].keyButton)
            and not self.cases[i].isOpened
            and not self.cases[i].chosenCase
            and not self.haltPresses
            and not (self.casesToOpen <= self.casesOpened) then
                -- Halt any presses as we picked a case
                self.haltPresses = true

                -- Play a sound effect confirming our choice
                gameAudio['select']:stop()
                gameAudio['select']:play()

                -- Open the case
                self.cases[i]:openCase()

                -- Wait until animation finishes
                Timer.after(1, function()
                    -- Increment # of cases opened
                    self.casesOpened = self.casesOpened + 1
                    -- After 3 seconds, move to banker state
                    -- If we exceed the # of cases to open,
                    -- the round is over.
                    if self.casesToOpen <= self.casesOpened then
                        self.promptText = "Round Over"
                        
                        -- Count the number of cases left to open
                        local casesLeft = 0
                        for j = 1, #CASE_VALUES do
                            if not self.cases[j].isOpened then
                                casesLeft = casesLeft + 1
                            end
                        end

                        -- Fade out text after 3 seconds
                        -- then move to appropriate state
                        Timer.after(3, function()
                            Timer.tween(1, {
                                [self] = {fadeAlpha = 255}
                            }):finish(function()
                                -- Stop music
                                gameAudio['think']:stop()
                                -- If more than 2 cases left to see, go to offer state
                                if casesLeft > 2 then
                                    gameStateMachine:change('offer', {
                                        cases = self.cases,
                                        casesToOpen = self.casesToOpen
                                    })
                                -- Otherwise, go to results state
                                else
                                    -- Local vars to store remaining and chosen case
                                    local caseRemain = {}
                                    local caseChoesn = {}
                                    -- Check cases and grab remaining and chosen case
                                    for i = 1, #CASE_VALUES do
                                        if not self.cases[i].isOpened
                                        and not self.cases[i].chosenCase then
                                            caseRemain = self.cases[i]
                                        elseif self.cases[i].chosenCase then
                                            caseChoesn = self.cases[i]
                                        end
                                    end
                                    -- Send chosen + remaining to result
                                    gameStateMachine:change('result', {
                                        remainingCase = caseRemain,
                                        chosenCase = caseChoesn
                                    })
                                end
                            end)
                        end)
                    else
                        -- Update prompt text
                        self.promptText = "Open " .. self.casesToOpen - self.casesOpened .. " Container"
                        if not ((self.casesToOpen - self.casesOpened) == 1) then
                            self.promptText = self.promptText .. "s"
                        end
                        -- Allow control again
                        self.haltPresses = false
                    end
                end)
            end
        end
    end

    -- Update timer
    Timer.update(dt)
end

function PlayState:render()
    -- Draw cases and scoreboard
    for i = 1, #CASE_VALUES do
        self.cases[i]:render()
        self.scoreBoard[i]:render()
    end

    -- Print the prompts
    self:printPrompt(self.promptText, self.promptAlpha)

    -- Rectangle that fills the whole screen,
    -- providing a transition effect using a
    -- variable alpha value.
    love.graphics.setColor(255, 255, 255, self.fadeAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function PlayState:printPrompt(text, alpha)
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