Logic = {}

Logic[Pawn] = function(piece, x, y)
    if y == 1 or y == 8 then
        return nil
    end
    local t = {}
    local up = piece[1] == 'White' and 1 or -1
    if Board[y + up][x] == nil then
        table.insert(t, { x = x, y = y + 1 })
    end
    return t
end
