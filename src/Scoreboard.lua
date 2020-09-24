-- Deal50: A game inspired by the TV show
-- Developed by Joaquin
-- Final project for GD50 2020

Scoreboard = Class{}

function Scoreboard:init(def)
    -- Point to a case to reference from
    self.refCase = def.refCase or Case()

    -- Visual X and Y position of the score board
    self.x = def.x or 0
    self.y = def.y or 0

    -- Visual control variables for score board graphics
    self.alphaTransition = def.alphaTransition or 0
end

function Scoreboard:render()
    -- Scoreboard texture would be kinda like the cases,
    -- but variables depend on the value of the case that
    -- the board is pointing to.

    -- Set colors based on alpha transition value.
    love.graphics.setColor(255, 255, 255, self.alphaTransition)

    -- Display the value of the case
    -- Set font size for case value
    love.graphics.setFont(gameFonts['medium'])

    -- If the pointed case is open
    if self.refCase.displayValue then
        -- Draw dim board
        love.graphics.draw(gameTex['score'], gameFrames['score'][2], self.x, self.y, 0, 2, 2)
        -- Display value; color is already set to white
        love.graphics.printf(
            self:abbreviateValue(self.refCase.pointValue),
            self.x, self.y + 8, TILE_SIZE*2, 'center'
        )
    else
        -- Draw lit-up board
        love.graphics.draw(gameTex['score'], gameFrames['score'][1], self.x, self.y, 0, 2, 2)
        -- Set color to black
        love.graphics.setColor(0, 0, 0, self.alphaTransition)
        -- Display value
        love.graphics.printf(
            self:abbreviateValue(self.refCase.pointValue),
            self.x, self.y + 8, TILE_SIZE*2, 'center'
        )
    end
end

-- Function returns an abbreviated value
function Scoreboard:abbreviateValue(points)
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