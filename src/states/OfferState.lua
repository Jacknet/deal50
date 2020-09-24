-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

OfferState = Class{__includes = BaseState}

function OfferState:init()
    -- Play suspenseful music and set it to loop
    gameAudio['suspense']:setLooping(true)
    gameAudio['suspense']:play()
    
    -- Set background color to red
    UpdateBG(255, 0, 0)

    -- Flag to halt input during animations
    self.haltPresses = true

    -- Variable to hold the cases
    self.cases = {}

    -- Store score boards to display
    self.scoreBoard = {}

    -- Variable to store the number of cases left.
    self.casesToOpen = 0

    -- Alpha variable for when we enter and exit the state. 
    self.fadeAlpha = 255
    
    -- Variable to store option number. Default is DENY.
    self.selection = 2

    -- Variable to store a banker object which processes
    -- the offer for the user's case
    self.banker = {}
end

function OfferState:enter(params)
    -- Grab the cases that were passed from
    -- the prior state and store them for use here.
    self.cases = params.cases or {}

    -- Grab casesToOpen
    -- A decremented value, if greater tahn 1,
    -- will be returned later should player deny
    -- banker deal. Fallback 6.
    self.casesToOpen = params.casesToOpen or 6

    -- Instantiate scoreboard, ensuring it's already visible
    for i = 1, #CASE_VALUES do
        if i <= #CASE_VALUES/2 then
            table.insert(self.scoreBoard, Scoreboard({
                refCase = self.cases[i] or Case(),
                x = (TILE_SIZE*2) * (i),
                y = VIRTUAL_HEIGHT - (TILE_SIZE*5),
                alphaTransition = 255
            }))
        else
            table.insert(self.scoreBoard, Scoreboard({
                refCase = self.cases[i] or Case(),
                x = (TILE_SIZE*2) * ((i-(#CASE_VALUES/2))),
                y = VIRTUAL_HEIGHT - (TILE_SIZE*3),
                alphaTransition = 255
            }))
        end
    end

    -- Instantiate banker which will process cases and hold offer
    self.banker = Banker({
        cases = self.cases,
        casesToOpen = self.casesToOpen
    })

    -- Wait half a second due to the pre-gap in the music,
    -- then run fade animation.
    -- MOVE haltPresses false to where prompt is shown!
    Timer.after(0.5, function()
        Timer.tween(1, {
            [self] = {fadeAlpha = 0}
        }):finish(function() self.haltPresses = false end)
    end)
end

function OfferState:update(dt)
    -- Press escape at any time to quit, regardless
    -- if haltPresses is on during transitions.
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- If input is not halted
    if not self.haltPresses then
        -- If we press left and are not selecting ACCEPT
        if love.keyboard.wasPressed('left') and not (self.selection == 1) then
            -- Play cursor sound
            gameAudio['cursor']:stop()
            gameAudio['cursor']:play()
            -- Set selection to ACCEPT
            self.selection = 1
        -- Else if we press right and are not selecting DENY
        elseif love.keyboard.wasPressed('right') and not (self.selection == 2) then
            -- Play cursor sound
            gameAudio['cursor']:stop()
            gameAudio['cursor']:play()
            -- Set selection to DENY
            self.selection = 2
        end

        -- If user accepts the offer
        if love.keyboard.wasPressed('space') and (self.selection == 1) then
            -- Set haltPresses to true
            self.haltPresses = true
            
            -- Play Deal sound
            gameAudio['deal']:play()

            -- Fade out text after 3 seconds then move to result state
            Timer.tween(1, {
                [self] = {fadeAlpha = 255}
            }):finish(function()
                -- Stop music
                gameAudio['suspense']:stop()
                -- Grab chosen case
                local caseChosen = {}
                for i = 1, #CASE_VALUES do
                    if self.cases[i].chosenCase then
                        caseChosen = self.cases[i]
                        break
                    end
                end
                -- Send offer and chosen case to result
                gameStateMachine:change('result', {
                    bankerOffer = self.banker.offer,
                    chosenCase = caseChosen
                })
            end)
        -- Else if user declines the offer
        elseif love.keyboard.wasPressed('space') and (self.selection == 2) then
            -- Set haltPresses to true
            self.haltPresses = true
            
            -- Play No Deal sound
            gameAudio['nodeal']:play()

            -- Decrement casesToOpen if it is greater than 1
            if self.casesToOpen > 1 then
                self.casesToOpen = self.casesToOpen - 1
            end

            -- Fade out text after 3 seconds then move to play state
            Timer.tween(1, {
                [self] = {fadeAlpha = 255}
            }):finish(function()
                gameAudio['suspense']:stop()
                gameStateMachine:change('play', {
                    cases = self.cases,
                    casesToOpen = self.casesToOpen,
                    fadeAlpha = self.fadeAlpha
                })
            end)
        end
    end

    -- Update banker graphics
    self.banker:update()

    -- Update timer
    Timer.update(dt)
end

function OfferState:render()
    -- Draw scoreboard and our case
    for i = 1, #CASE_VALUES do
        if self.cases[i].chosenCase then
            self.cases[i]:render()
        end
        self.scoreBoard[i]:render()
    end

    -- Render selectable buttons
    self:buttons(self.selection)

    -- Render the banker
    self.banker:render()

    -- Rectangle that fills the whole screen,
    -- providing a transition effect using a
    -- variable alpha value.
    love.graphics.setColor(255, 255, 255, self.fadeAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function OfferState:buttons(selection)
    -- Local variables that store the
    -- "brightness" for the labels
    -- and a cursor reminder to ensure the
    -- user knows what to press to move selection
    local selectBrightY, selectBrightN, arrowX = 0, 0, 0
    local arrowReminder = ""

    -- If ACCEPT is selected, store 200 to it,
    -- 0 to DENY, and place -> arrow
    if selection == 1 then
        selectBrightY = 200
        selectBrightN = 0
        arrowReminder = "->"
        arrowX = (VIRTUAL_WIDTH/2)+112
    -- Else if DENY is elected, store 200 to
    -- that, 0 to ACCEPT, and place <- arrow
    elseif selection == 2 then
        selectBrightY = 0
        selectBrightN = 200
        arrowReminder = "<-"
        arrowX = VIRTUAL_WIDTH/4
    end

    -- Set prompt font
    love.graphics.setFont(gameFonts['medium'])

    -- Render ACCEPT button with green color
    love.graphics.setColor(0, 55+selectBrightY, 0, 128)
    love.graphics.rectangle('fill', (VIRTUAL_WIDTH/4)-16, (VIRTUAL_HEIGHT/2)+16, 128, 32)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf("ACCEPT", (VIRTUAL_WIDTH/4)-15, (VIRTUAL_HEIGHT/2)+24, 128, 'center')

    -- Render DENY button with red color
    love.graphics.setColor(55+selectBrightN, 0, 0, 128)
    love.graphics.rectangle('fill', (VIRTUAL_WIDTH/4)+144, (VIRTUAL_HEIGHT/2)+16, 128, 32)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf("DENY", (VIRTUAL_WIDTH/4)+144, (VIRTUAL_HEIGHT/2)+24, 128, 'center')

    -- Render arrow reminder within button based on arrowX
    love.graphics.printf(arrowReminder, arrowX, (VIRTUAL_HEIGHT/2)+24, 16, 'center')
end
