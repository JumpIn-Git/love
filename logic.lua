Logic = {}

Logic[Pawn] = function(piece, tileX, tileY)
    if tileY == 1 or tileY == 8 then
        return {}
    end
    local t = {}
    local up = piece[1] == 'White' and -1 or 1
    if Board[tileY + up][tileX] == nil then
        table.insert(t, { x = tileX, y = tileY + up })
    end
    return t
end
