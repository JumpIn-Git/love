require 'tile'
require 'board'
require 'mouse'
require 'logic'

function love.draw()
    push:start()
    love.graphics.scale(3, 3)
    Board:draw()
    push:finish()
end

function love.update()
    if love.keyboard.isDown('r') then
        Board.reset()
    end
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    Offset = 7 * 3
    Tile = 16 * 3
    _G.push = require 'push'
    local w, h = love.graphics.getDimensions()
    -- Make 3x board so moving a peice isnt jittery
    push:setupScreen(142 * 3, 142 * 3, w, h, { fullscreen = true })
end
