Logic = {}
local function outOfBounds(tX, tY, x, y)
    if tX + x > 8 or tX + x < 1 or
        tY + y > 8 or tY + y < 1 then
        return true
    end
    return false
end

Logic[Pawn] = function(piece, tX, tY)
    if tY == 1 or tY == 8 then
        return {}
    end
    local t = {}
    if Board[tY + -1][tX] == nil then
        table.insert(t, { x = tX, y = tY + -1 })
    end
    return t
end

--TODO detects fields out of board? and doesnt work now?
Logic[Bishop] = function(piece, tX, tY)
    local t = {}
    for _, x in ipairs { 1, -1 } do
        for _, y in ipairs { 1, -1 } do
            if outOfBounds(tX, tY, x, y) then goto continue end
            local nextX, nextY = tX + x, tY + y
            while nextX >= 1 and nextX <= 8 and nextY >= 1 and nextY <= 8 and Board[nextY][nextX] == nil do
                table.insert(t, { x = nextX, y = nextY })
                nextX, nextY = nextX + x, nextY + y
            end
            -- Stopped checking at other color, we can kill
            if nextX >= 1 and nextX <= 8 and nextY >= 1 and nextY <= 8 and Board[nextY][nextX] and Board[nextY][nextX][1] ~= piece[1] then
                table.insert(t, { x = nextX, y = nextY })
            end
            ::continue::
        end
    end
    return t
end

Logic[King] = function(piece, tX, tY)
    local t = {}
    for _, x in ipairs { 1, 0, -1 } do
        for _, y in ipairs { 1, 0, -1 } do
            if outOfBounds(tX, tY, x, y) then goto continue end
            local targeting = Board[tY + y][tX + x]
            if targeting == nil or targeting[1] ~= piece[1] then
                table.insert(t, { x = tX + x, y = tY + y })
            end
            ::continue::
        end
    end
    return t
end

Logic[Horse] = function(piece, tX, tY)
    local moves = { { 1, 2 }, { 2, 1 }, { -1, 2 }, { -2, 1 }, { 1, -2 }, { 2, -1 }, { -1, -2 }, { -2, -1 } } --{x,y}
    local t = {}
    for _, move in ipairs(moves) do
        local x, y = unpack(move)
        if outOfBounds(tX, tY, x, y) then goto continue end
        local targeting = Board[tY + y][tX + x]
        if targeting == nil or targeting[1] ~= piece[1] then
            table.insert(t, { x = tX + x, y = tY + y })
        end
        ::continue::
    end
    return t
end
