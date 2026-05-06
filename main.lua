function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    Offset = 7 -- Tiles begin here
    Tile = 16  -- Px per tile
    Selected = nil
    Turn = 'White'
    Gameover = false
    Winner = nil
    love.graphics.setFont(love.graphics.newFont(24 * 5))
    _G.push = require 'push'
    local w, h = love.graphics.getDimensions()
    -- *5 for clear circles
    push:setupScreen(142 * 5, 142 * 5, w, h, { fullscreen = true })

    require 'tile'
    require 'board'
    require 'logic'
    require 'mouse'
end

function love.draw()
    push:start()
    love.graphics.scale(5, 5)
    Board:draw()
    push:finish()
    if Gameover then
        love.graphics.print(string.format("%s won!", Winner))
    end
end
