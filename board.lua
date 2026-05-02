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
    for tileY, row in ipairs(Board) do
        for tileX, piece in pairs(row) do
            if piece then
                local color, type = unpack(piece)
                local x, y = Offset + ((tileX - 1) * 16), Offset + ((tileY - 1) * 16)
                if piece == Selected then
                    print(tileX .. tileY)
                    Selected.x, Selected.y = x, y
                    Selected.tileY, Selected.tileX = tileY, tileX
                end
                love.graphics.draw(_G[color].img, _G[color][type], x, y)
            end
        end
    end
    if Selected then
        love.graphics.circle("line", Selected.x + Tile / 2, Selected.y + Tile / 2, Tile / 2)
        if Logic[Selected[2]] then
            local canMoveTo = Logic[Selected[2]](Selected, Selected.tileX, Selected.tileY)
            for _, i in ipairs(canMoveTo) do
                love.graphics.circle("line", Offset - Tile / 2 + (i.x * 16), Offset - Tile / 2 + (i.y * 16), Tile / 2)
            end
        end
    end
end

Board.reset()
