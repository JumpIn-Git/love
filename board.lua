Board = {} -- Board[Row(y)][Column(x)]
Board.img = love.graphics.newImage("tiles/boards/board_plain_05.png")
Board.img:setFilter('nearest', 'nearest')
Board.idx = 5

function love.keypressed(key)
    if key == "space" then
        Board.idx = Board.idx + 1
        if Board.idx == 6 then
            Board.idx = 1
        end
        Board.img = love.graphics.newImage(string.format("tiles/boards/board_plain_0%d.png", Board.idx))
        Board.img:setFilter('nearest', 'nearest')
    end
    if key == 'r' then
        Board.reset()
        if Turn ~= 'White' then Board.reverse() end
    end
end

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

Board.reset()

function Board.draw()
    love.graphics.draw(Board.img)
    for tY, row in ipairs(Board) do
        for tX, piece in pairs(row) do
            if piece then
                local color, type = unpack(piece)
                local x, y = Offset + ((tX - 1) * Tile), Offset + ((tY - 1) * Tile)
                if piece == Selected then
                    Selected.x, Selected.y = x, y
                    Selected.tY, Selected.tX = tY, tX
                end
                love.graphics.draw(_G[color].img, _G[color][type], x, y)
            end
        end
    end
    if Selected then
        love.graphics.circle("line", Selected.x + Tile / 2, Selected.y + Tile / 2, Tile / 2)
        if Logic[Selected[2]] then
            Selected.canMoveTo = Logic[Selected[2]](Selected, Selected.tX, Selected.tY)
            for _, i in ipairs(Selected.canMoveTo) do
                love.graphics.circle("line",
                    Offset + (i.x * Tile) - Tile / 2,
                    Offset + (i.y * Tile) - Tile / 2,
                    Tile / 2)
            end
        end
    end
end

function Board.reverse()
    -- local i, j = 1, #Board
    -- while i < j do
    --     Board[i], Board[j] = Board[j], Board[i]
    --     i = i + 1
    --     j = j - 1
    -- end

    Turn = Turn == 'White' and 'Black' or 'White'
end
