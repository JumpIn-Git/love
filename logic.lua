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
    local up = Turn == 'White' and -1 or 1
    local start = Turn == 'White' and 7 or 2
    local t = {}
    if Board[tY + up][tX] == nil then
        table.insert(t, { x = tX, y = tY + up })
    end
    if tY == start and Board[tY + up + up][tX] == nil then
        table.insert(t, { x = tX, y = tY + up + up })
    end
    for _, i in ipairs { 1, -1 } do
        if tX + i > 8 or tX + i < 1 then goto continue end
        if Board[tY + up][tX + i] and Board[tY + up][tX + i][1] ~= piece[1] then
            table.insert(t, { x = tX + i, y = tY + up })
        end
        ::continue::
    end
    return t
end

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

Logic[Tower] = function(piece, tX, tY)
    local t = {}
    for _, x in ipairs { 1, -1 } do
        local nextX = tX + x
        if nextX > 8 or nextX < 1 then goto continue_x end

        while nextX <= 8 and nextX >= 1 and Board[tY][nextX] == nil do
            table.insert(t, { x = nextX, y = tY })
            nextX = nextX + x
        end
        if nextX <= 8 and nextX >= 1 and Board[tY][nextX] then
            if Board[tY][nextX][1] ~= piece[1] then
                table.insert(t, { x = nextX, y = tY })
            end
        end
        ::continue_x::
    end
    for _, y in ipairs { 1, -1 } do
        local nextY = tY + y
        if nextY > 8 or nextY < 1 then goto continue_y end
        while nextY <= 8 and nextY >= 1 and Board[nextY][tX] == nil do
            table.insert(t, { x = tX, y = nextY })
            nextY = nextY + y
        end
        if nextY <= 8 and nextY >= 1 and Board[nextY][tX] then
            if Board[nextY][tX][1] ~= piece[1] then
                table.insert(t, { x = tX, y = nextY })
            end
        end
        ::continue_y::
    end

    return t
end

Logic[Queen] = function(...)
    local function tableMerge(...)
        local result = {}
        for _, t in ipairs({ ... }) do
            for _, v in ipairs(t) do
                table.insert(result, v)
            end
        end
        return result
    end

    return tableMerge(Logic[Bishop](...), Logic[Tower](...))
end
