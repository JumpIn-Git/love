function love.load()
    Offset = 7 -- Tiles begin here
    Tile = 16  -- Px per tile
    Selected = nil

    Color = nil
    Gamestarted = false -- 2 clients connected?
    Ourturn = false

    Gameover = false
    Winner = nil
    love.graphics.setFont(love.graphics.newFont(24 * 5))

    love.graphics.setDefaultFilter('nearest', 'nearest')
    _G.push = require 'push'
    local w, h = love.graphics.getDimensions()
    push:setupScreen(142 * 5, 142 * 5, w, h, { fullscreen = true }) -- *5 for clear circles

    local socket = require 'socket'
    Client = socket.tcp()
    Client:settimeout(0)
    Client:connect('127.0.0.1', 12345)

    require 'tile'
    require 'board'
    require 'logic'
    require 'mouse'
end

function love.update()
    local data = Client:receive('*l')
    if not data then return end
    if not Color then
        Color = data
        Ourturn = Color == 'White'
        if Color == 'Black' then
            Board.reverse()
        end
        return
    end
    if not Gamestarted and data == 'gamestart' then
        Gamestarted = true
        return
    end
    -- Move has been received
    print(Color .. ' received ' .. data)
    data = loadstring(data)()
    Ourturn = true
    local fromX, fromY, toX, toY = unpack(data)
    Gameover = data[5]
    if Gameover then
        Winner = Color == 'White' and 'Black' or 'White'
    end
    Board[toY][toX] = Board[fromY][fromX]
    Board[fromY][fromX] = nil
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
