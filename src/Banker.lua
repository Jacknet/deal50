-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

Banker = Class{}

function Banker:init(def)
    -- Grab cases
    self.cases = def.cases or {}

    -- Grab number of cases to open
    self.casesToOpen = def.casesToOpen or 6

    -- Count the number of unopened cases and store their total,
    -- along with storing the maximum case value within the pool
    -- of unopened cases.
    self.unopenedCount = 0
    self.unopenedTotal = 0
    self.maxCaseValue = 0
    for i = 1, #CASE_VALUES do
        if not self.cases[i].isOpened then
            self.unopenedCount = self.unopenedCount + 1
            self.unopenedTotal = self.unopenedTotal + self.cases[i].pointValue
            if self.cases[i].pointValue > self.maxCaseValue then
                self.maxCaseValue = self.cases[i].pointValue
            end
        end
    end

    --[[
        Calculate the banker's offer.

        The algorithm implemented here starts with
        more stingy values if the casesToOpen rate
        is high, as seen in the first rounds, but
        makes more refined offers as the player
        nears the end of the game.

        Get the whole total of unopened case
        values, divided by number of cases minus
        a random value from 0, to unopened count
        minus 1 divided by number of cases left
        to open plus 1. Plus a random value from
        0, to 1000 divided by number of cases to
        open. Use math.ceil to round out value.

        Check up to 10 times. If offer is higher
        than max case value, divide offer by 1.5
        and keep dividing until it is lower than
        the max case value amount.
    ]]
    self.offer = math.ceil(
        (
            self.unopenedTotal/(
                self.unopenedCount - math.random(0, (self.unopenedCount-1)/(self.casesToOpen+1))
            )
        ) + math.random(0, 1000/self.casesToOpen)
    )
    for i = 1, 10 do
        if self.offer > self.maxCaseValue then
            self.offer = math.ceil(self.offer/1.5)
        else
            break
        end
    end

    -- Animation frame
    self.animFrame = 1

    -- X flip that should store either 1 or -1
    self.xFlip = 1

    -- Boolean toggles for tweens
    self.blink = true
    self.tail = true
end

function Banker:update()
    -- Blink when random value from 1 to 500
    -- equals 1 and we're not blinking yet
    if (math.random(1, 500) == 1) and self.blink then
        self.blink = false
        self.animFrame = 2
        Timer.after(0.25, function()
            self.animFrame = 1
            self.blink = true
        end)
    end
    -- Flail tail when random value from 1 to 500
    -- equals 1 and we're not blinking yet
    if (math.random(1, 500) == 1) and self.tail then
        self.tail = false
        self.xFlip = -1
        Timer.after(0.25, function()
            self.xFlip = 1
            self.tail = true
        end)
    end
end

function Banker:render()
    -- Local variable to store position multiple
    -- when mirroring from X
    local xFlipPos = 1

    -- If flipping, set flip pos multiple to 4
    if self.xFlip == -1 then
        xFlipPos = 2.5
    end

    self:printPrompt("I would like to offer", 0)
    self:printOffer(self.offer)
    self:printPrompt("points", 70)

    -- Render banker graphic
    love.graphics.draw(
        -- Use cat graphic
        gameTex['cat'], gameFrames['cat'][self.animFrame],
        -- Position on the top left of the screen
        -- Nudge position accordingly if graphic is flipped
        (VIRTUAL_WIDTH/6)*xFlipPos, VIRTUAL_HEIGHT/24,
        -- No rotate
        0,
        -- Scale by 4, flip when needed
        4*self.xFlip, 4
    )
end

function Banker:printPrompt(text, yOffset)
    -- Set prompt font
    love.graphics.setFont(gameFonts['medium'])

    -- Set shadow color
    love.graphics.setColor(0, 0, 0, 255 / 2)
    -- Print enter prompt shadow
    love.graphics.printf(text, 59, (VIRTUAL_HEIGHT / 12 + 1) + 20 + yOffset, VIRTUAL_WIDTH, 'center')

    -- Set the color for the prompt
    love.graphics.setColor(255, 255, 255, 255)
    -- Print the prompt
    -- The prompt is shifted by one pixel to the
    -- left to avoid nearest neighbor artifacting.
    love.graphics.printf(text, 57, (VIRTUAL_HEIGHT / 12 - 1) + 20 + yOffset, VIRTUAL_WIDTH, 'center')
end

function Banker:printOffer(offer)
    -- Set offer font
    love.graphics.setFont(gameFonts['title'])

    -- Set shadow color
    love.graphics.setColor(0, 0, 0, 255 / 2)
    -- Print enter offer shadow
    love.graphics.printf(offer, 60, (VIRTUAL_HEIGHT / 12 + 1) + 20, VIRTUAL_WIDTH, 'center')

    -- Set the color for the offer to yellow
    love.graphics.setColor(255, 255, 0, 255)
    -- Print the offer
    -- The offer is shifted by one pixel to the
    -- left to avoid nearest neighbor artifacting.
    love.graphics.printf(offer, 58, (VIRTUAL_HEIGHT / 12 - 1) + 20, VIRTUAL_WIDTH, 'center')
end