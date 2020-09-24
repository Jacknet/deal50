-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

Case = Class{}

function Case:init(def)
    -- Variable to store the case's point value
    self.pointValue = def.pointValue or 0
    -- Variable to store the case's key as a string/character
    self.keyButton = def.keyButton or ''

    -- Variable to flag whether this case is open
    self.isOpened = false

    -- Flag that definies if this is the player's case
    self.chosenCase = false

    -- Visual X and Y position of the case
    self.x = def.x or 0
    self.y = def.y or 0
    -- Visual control variables for case graphics
    self.visualTransition = 0
    self.caseOpenFrame = 1
    self.displayKey = false
    self.displayValue = false
    self.toHide = false
end

function Case:render()
    -- If case is not hidden after returning from banker to play
    if not self.toHide then
        -- Set color based on visual transition value.
        love.graphics.setColor(self.visualTransition, self.visualTransition, self.visualTransition, 255)

        -- Draw the case if not hidden from play
        -- Scaled by 2
        love.graphics.draw(gameTex['case'], gameFrames['case'][math.floor(self.caseOpenFrame)], self.x, self.y, 0, 2, 2)

        -- Display the value of the case
        -- Set font size for case value
        love.graphics.setFont(gameFonts['medium'])
        -- Print appropriate values
        if self.displayKey then
            -- Set color to black
            love.graphics.setColor(0, 0, 0, 255)
            -- Print key that identifies the case
            love.graphics.printf(string.upper(self.keyButton), self.x, self.y + 10, TILE_SIZE*2, 'center')
        elseif self.displayValue then
            -- Set color to white
            love.graphics.setColor(255, 255, 255, 255)
            -- Display case's value
            love.graphics.printf(
                self:abbreviateValue(self.pointValue),
                self.x, self.y + 10, TILE_SIZE*2, 'center'
            )
        end
    end
end

-- Function to make the case appear after the title screen
function Case:appearCase()
    -- Brighten up case
    Timer.tween(1, {
        [self] = {visualTransition = 255}
    })
end

-- Function to animate the case
function Case:openCase()
    -- Set case to opened
    self.isOpened = true
    -- Hide key
    self.displayKey = false
    -- Animate transition
    Timer.tween(1, {
        [self] = {caseOpenFrame = 4}
    }):finish(function()
        -- Show case value
        self.displayValue = true
        -- If self value is less than 1000
        if self.pointValue < 1000 then
            -- Play good audio
            gameAudio['good']:stop()
            gameAudio['good']:play()
        else
            -- Else play bad audio
            gameAudio['bad']:stop()
            gameAudio['bad']:play()
        end
    end)
end

-- Function to move case position
-- and set new key during shuffling
function Case:moveCase(newX, newY, newKey)
    -- Set new key corresponding the case
    self.keyButton = newKey
    -- Tween new X and Y
    Timer.tween(1, {
        [self] = {x = newX}
    })
    Timer.tween(1, {
        [self] = {y = newY}
    })
end

-- Function returns an abbreviated value
function Case:abbreviateValue(points)
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