Board = {} -- Board[Row(y)][Column(x)]
Board.img = love.graphics.newImage("tiles/boards/board_plain_05.png")
Board.img:setFilter('nearest', 'nearest')

function Board.reset()
    for i = 1, 8 do Board[i] = {} end
    for _ = 1, 8 do
        table.insert(Board[2], { 'Black', Pawn })
        table.insert(Board[7], { 'White', Pawn })
    end
    local t = { Tower, Horse, Bishop, King, Queen, Bishop, Horse, Tower }
    for _, piece in ipairs(t) do
        table.insert(Board[1], { 'Black', piece })
        table.insert(Board[8], { 'White', piece })
    end
end

function Board.draw()
    love.graphics.draw(Board.img)
    local data = {}
    for rowIdx, row in ipairs(Board) do
        for columnIdx, piece in pairs(row) do
            if piece then
                local color, type = unpack(piece)
                local x, y = 7 + ((columnIdx - 1) * 16), 7 + ((rowIdx - 1) * 16)
                if piece == Selected then
                    data.x, data.y = x, y
                    data.rowIdx, data.columnIdx = rowIdx, columnIdx
                end
                love.graphics.draw(_G[color].img, _G[color][type], x, y)
            end
        end
    end
    if Selected then
        love.graphics.circle("line", data.x + 8, data.y + 8, 8)
        if Logic[Selected[2]] then
            local canMoveTo = Logic[Selected[2]](Selected, data.columnIdx, data.rowIdx)
            for _, i in ipairs(canMoveTo) do
                love.graphics.circle("line", 7 + i.x * 16, 7 + i.y * 16, 8)
            end
        end
    end
end

Board.reset()
