-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

ResultState = Class{__includes = BaseState}

function ResultState:init()
    -- Play action music and set it to loop
    gameAudio['action']:setLooping(true)
    gameAudio['action']:play()

    -- Set color to yellow
    UpdateBG(255, 128, 0)

    -- Variable to store chosen case
    self.chosenCase = {}

    -- Variable to store remaining case
    self.remainingCase = {}

    -- Default -1 meaning no offer
    self.bankerOffer = -1

    -- Alpha variable for when we enter and exit the state. 
    self.fadeAlpha = 255

    -- Variables for text alphas
    self.fadeText = 255
    self.fadeFinalScore = 0

    -- Variable to store final score
    self.finalScore = 0

    -- Y and frame values for case animations
    self.caseAnimFrame = 1
    self.caseAnimY = (VIRTUAL_HEIGHT/2)-(TILE_SIZE*2.5)

    -- Flag for showing score after animations are finished.
    self.showScore = false
end

function ResultState:enter(params)
    -- Grab the player's case.
    self.chosenCase = params.chosenCase or {}

    -- Grab the remaining case if any.
    self.remainingCase = params.remainingCase or {}

    -- Grab bank offer if any.
    self.bankerOffer = params.bankerOffer or -1

    -- If a bank offer is given, use that as the final score.
    -- If no bank offer, then use our case value as the final
    -- score and allow remaining case animation.
    if self.bankerOffer > -1 then
        self.finalScore = self.bankerOffer
    else
        self.finalScore = self.chosenCase.pointValue
    end

    -- Fade in
    Timer.tween(1, {
        [self] = {fadeAlpha = 0}
    })

    -- Open case after 2 seconds
    Timer.after(2, function()
        Timer.tween(1, {
            [self] = {caseAnimFrame = 4}
        }):finish(function()
            -- After case animation, reveal score
            self.showScore = true
            -- Play appropriate sound depending
            -- on whether the player won or lost
            if self.bankerOffer > -1 then
                -- If there's a bank offer and bank offer
                -- is greater than chosen case value.
                if self.bankerOffer >= self.chosenCase.pointValue then
                    -- Play good audio
                    gameAudio['good']:stop()
                    gameAudio['good']:play()
                else
                    -- Else play bad audio
                    gameAudio['bad']:stop()
                    gameAudio['bad']:play()
                end
            else
                -- If remaining case and chosen case value
                -- is greater than remaining case value.
                if self.chosenCase.pointValue >= self.remainingCase.pointValue then
                    -- Play good audio
                    gameAudio['good']:stop()
                    gameAudio['good']:play()
                else
                    -- Else play bad audio
                    gameAudio['bad']:stop()
                    gameAudio['bad']:play()
                end
            end
        end)
    end)

    -- Move case down and fade in final score
    Timer.after(4, function()
        Timer.tween(0.5, {
            [self] = {
                caseAnimY = VIRTUAL_HEIGHT+(TILE_SIZE*4),
                fadeFinalScore = 255
            }
        })
    end)

    -- After 3 seconds of result, fade out
    -- text and go to game over state.
    Timer.after(5, function()
        Timer.tween(1, {
            [self] = {fadeText = 0}
        }):finish(function()
            -- Send final score to game over state.
            -- No need to stop the music for next
            -- state as the track continues there.
            gameStateMachine:change('game-over', {
                finalScore = self.finalScore
            })
        end)
    end)
end

function ResultState:update(dt)
    -- Press escape at any time to quit, regardless
    -- if haltPresses is on during transitions.
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- Update timer
    Timer.update(dt)
end

function ResultState:render()
    -- Print the score if shown
    self:printScore(self.finalScore, self.fadeFinalScore)

    -- Case renders will be overridden in
    -- this state to make it 6x larger
    -- if banker offer is accepted or
    -- two cases 4x larger if remaining case
    if self.bankerOffer > -1 then
        -- Run banker mode graphics
        self:bankerAnim(
            self.chosenCase,
            self.caseAnimFrame, self.caseAnimY,
            self.fadeText, self.showScore
        )
    else
        -- Else run remaining case mode graphics
        self:remainAnim(
            self.chosenCase, self.remainingCase,
            self.caseAnimFrame, self.caseAnimY,
            self.fadeText, self.showScore
        )
    end
    
    -- Print the "RESULTS" header
    self:printTitle("RESULTS", self.fadeText)

    -- Rectangle that fills the whole screen,
    -- providing a transition effect using a
    -- variable alpha value.
    love.graphics.setColor(255, 255, 255, self.fadeAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function ResultState:printTitle(text, alpha)
    -- Set font
    love.graphics.setFont(gameFonts['title'])
    -- Print shadow
    love.graphics.setColor(0, 0, 0, alpha / 2)
    love.graphics.printf(text, 3, VIRTUAL_HEIGHT / 8 + 3, VIRTUAL_WIDTH, 'center')
    -- Print text
    love.graphics.setColor(255, 255, 0, alpha)
    love.graphics.printf(text, 0, VIRTUAL_HEIGHT / 8, VIRTUAL_WIDTH, 'center')
end

function ResultState:printScore(score, alpha)
    -- Set font
    love.graphics.setFont(gameFonts['large'])
    -- Print shadow
    love.graphics.setColor(0, 0, 0, alpha / 2)
    love.graphics.printf(score, 5, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    -- Print text
    love.graphics.setColor(255, 255, 255, alpha)
    love.graphics.printf(score, 1, VIRTUAL_HEIGHT / 2 - 3, VIRTUAL_WIDTH, 'center')
end

function ResultState:printPraise(alpha)
    -- Set font
    love.graphics.setFont(gameFonts['medium'])
    
    -- Local variable that will
    -- store appropriate text.
    local text

    -- If there is a bank offer
    if self.bankerOffer > -1 then
        -- If bank offer taken is greater than or equal to
        -- chosen case's point value, the user wins!
        if self.bankerOffer >= self.chosenCase.pointValue then
            text = "Good Deal! You Win!"
        else
            -- Otherwise, they lost.
            text = "Bad Deal. Better Luck Next Time!"
        end
    else
        -- If there is no bank offer, if chosen case's point value
        -- is greater than the remaining case, the user wins!
        if self.chosenCase.pointValue >= self.remainingCase.pointValue then
            text = "Good Container! You Win!"
        else
            -- Otherwise, they lost.
            text = "Bad Container. Better Luck Next Time!"
        end
    end
    
    -- Print text
    love.graphics.setColor(0, 0, 0, alpha / 2)
    love.graphics.printf(text, 2, VIRTUAL_HEIGHT / 1.25 + 2, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, alpha)
    love.graphics.printf(text, 0, VIRTUAL_HEIGHT / 1.25, VIRTUAL_WIDTH, 'center')
end

-- Function returns an abbreviated value
function ResultState:abbreviateValue(points)
    -- If points is greater than 999
    if points > 999 then
        -- Divide points by 1000 and append a 'K'
        -- at the end and return the abbreviated value
        return (points / 1000) .. 'K'
    else
        -- Otherwise, just return the points
        return points
    end
end

-- Banker mode graphic functions
function ResultState:bankerAnim(chosen, animFrame, animY, fadeText, showScore)
    -- Set base color for draw and printf routines
    love.graphics.setColor(255, 255, 255, 255)
    -- If there is a bank offer, draw
    -- user case 6x large.
    love.graphics.draw(
        gameTex['case'],
        gameFrames['case'][math.floor(animFrame)],
        (VIRTUAL_WIDTH/2)-(TILE_SIZE*3), animY,
        0,
        6, 6
    )
    -- If score should be showed
    if showScore then
        -- Set large font
        love.graphics.setFont(gameFonts['large'])
        -- Print case's point value
        love.graphics.printf(
            self:abbreviateValue(chosen.pointValue),
            1, animY+(TILE_SIZE*2.5)-3,
            VIRTUAL_WIDTH,
            'center'
        )
        -- Print praise text below the screen
        self:printPraise(fadeText)
    end
end

-- Remaining case mode graphic functions
function ResultState:remainAnim(chosen, remain, animFrame, animY, fadeText, showScore)
    -- Set medium font size
    love.graphics.setFont(gameFonts['medium'])
    -- Print container marker shadow
    love.graphics.setColor(0, 0, 0, 255 / 2)
    love.graphics.printf(
        "YOUR CONTAINER",
        (-TILE_SIZE*6)+2, (animY+(TILE_SIZE*4))+2,
        VIRTUAL_WIDTH,
        'center'
    )
    -- Set base color for draw and printf routines
    love.graphics.setColor(255, 255, 255, 255)
    -- Print container marker
    love.graphics.printf(
        "YOUR CONTAINER",
        -TILE_SIZE*6, animY+(TILE_SIZE*4),
        VIRTUAL_WIDTH,
        'center'
    )
    -- Draw chosen case 4x
    love.graphics.draw(
        gameTex['case'],
        gameFrames['case'][math.floor(animFrame)],
        (VIRTUAL_WIDTH/2)-(TILE_SIZE*8), animY,
        0,
        4, 4
    )
    -- Draw remaining case 4x
    love.graphics.draw(
        gameTex['case'],
        gameFrames['case'][math.floor(animFrame)],
        (VIRTUAL_WIDTH/2)+(TILE_SIZE*4), animY,
        0,
        4, 4
    )
    -- If score should be showed
    if showScore then
        -- Set large font
        love.graphics.setFont(gameFonts['large'])
        -- Print chosen case's point value
        love.graphics.printf(
            self:abbreviateValue(chosen.pointValue),
            (-TILE_SIZE*6)+1, animY+(TILE_SIZE*1.5)-3,
            VIRTUAL_WIDTH,
            'center'
        )
        -- Print remaining case's point value
        love.graphics.printf(
            self:abbreviateValue(remain.pointValue),
            (TILE_SIZE*6)+1, animY+(TILE_SIZE*1.5)-3,
            VIRTUAL_WIDTH,
            'center'
        )
        -- Print praise text below the screen
        self:printPraise(fadeText)
    end
end