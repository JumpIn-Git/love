Logic = {}
local function isValid(x, y)
    return x >= 1 and x <= 8 and y >= 1 and y <= 8
end
local function addSlidingMoves(t, piece, tX, tY, directions)
    for _, dir in ipairs(directions) do
        local nX, nY = tX + dir[1], tY + dir[2]
        while isValid(nX, nY) do
            local target = Board[nY][nX]
            if not target then
                table.insert(t, { x = nX, y = nY })
            else
                if target[1] ~= piece[1] then
                    table.insert(t, { x = nX, y = nY })
                end
                break -- Hit a piece, stop sliding
            end
            nX, nY = nX + dir[1], nY + dir[2]
        end
    end
end

Logic[Pawn] = function(p, tX, tY)
    local t = {}
    if isValid(tX, tY + -1) and not Board[tY + -1][tX] then
        table.insert(t, { x = tX, y = tY + -1 })
        -- Double jump
        if tY == 7 and not Board[tY + -1 * 2][tX] then
            table.insert(t, { x = tX, y = tY + -1 * 2 })
        end
    end
    -- Capture
    for _, side in ipairs({ -1, 1 }) do
        local nX, nY = tX + side, tY + -1
        if isValid(nX, nY) and Board[nY][nX] and Board[nY][nX][1] ~= p[1] then
            table.insert(t, { x = nX, y = nY })
        end
    end
    return t
end

Logic[Horse] = function(p, tX, tY)
    local t = {}
    local offsets = { { 1, 2 }, { 2, 1 }, { -1, 2 }, { -2, 1 }, { 1, -2 }, { 2, -1 }, { -1, -2 }, { -2, -1 } }
    for _, o in ipairs(offsets) do
        local nX, nY = tX + o[1], tY + o[2]
        if isValid(nX, nY) then
            local target = Board[nY][nX]
            if not target or target[1] ~= p[1] then
                table.insert(t, { x = nX, y = nY })
            end
        end
    end
    return t
end

Logic[King] = function(p, tX, tY)
    local t = {}
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nX, nY = tX + dx, tY + dy
                if isValid(nX, nY) then
                    local target = Board[nY][nX]
                    if not target or target[1] ~= p[1] then
                        table.insert(t, { x = nX, y = nY })
                    end
                end
            end
        end
    end
    return t
end

local cardinals = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
local diagonals = { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }

Logic[Tower] = function(p, x, y)
    local t = {}
    addSlidingMoves(t, p, x, y, cardinals)
    return t
end

Logic[Bishop] = function(p, x, y)
    local t = {}
    addSlidingMoves(t, p, x, y, diagonals)
    return t
end

Logic[Queen] = function(p, x, y)
    local t = {}
    addSlidingMoves(t, p, x, y, cardinals)
    addSlidingMoves(t, p, x, y, diagonals)
    return t
end
