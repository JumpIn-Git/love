function love.load()
    local socket = require 'socket'
    Server = socket.bind('*', 12345)
    Server:settimeout(0)
    White, Black = nil, nil
    Color = 'White'
    love.graphics.setDefaultFilter('nearest', 'nearest')
end

function love.update()
    -- Game hasnt started
    if (not Black) or (not White) then
        local newClient = Server:accept()
        if newClient then
            newClient:settimeout(0)
            if White then
                Black = newClient
                Black:send('Black\n')
            else
                White = newClient
                White:send('White\n')
            end
            if Black and White then
                Black:send('gamestart\n')
                White:send('gamestart\n')
            end
        end
    else
        local data = _G[Color]:receive('*l')
        if data then
            Color = Color == 'White' and 'Black' or 'White'
            print('Server received ' .. data .. ', rerouting to ' .. Color)
            -- Pass data to other client
            _G[Color]:send(data .. '\n')
        end
    end
end

function love.draw()
    love.graphics.scale(2, 2)
    love.graphics.print('White ' .. (White and 'connected' or 'disconnected'))
    love.graphics.print('Black ' .. (Black and 'connected' or 'disconnected'), 0, 30)
end
