-- Work with scaling
local Offset = Offset * 3
local Tile = Tile * 3
local function mouseToTile(x, y)
    --TODO seems to be able to detect a extra tile? fix bound check
    if x <= 6 * 3 or x >= 135 * 3 or y <= 6 * 3 or y >= 135 * 3 then
        return nil, nil -- Out of bounds
    end
    return math.floor((x - Offset) / Tile) + 1, math.floor((y - Offset) / Tile) + 1
end
function love.mousepressed(x, y, b)
    if b ~= 1 then
        return
    end
    x, y = push:toGame(x, y)
    if x == nil or y == nil then return end
    x, y = mouseToTile(x, y)
    if x == nil then return end

    local pressed = Board[y][x]
    if Selected then
        -- Move to tile
        for _, i in ipairs(Selected.canMoveTo) do
            if i.x == x and i.y == y then
                Board[y][x] = Selected
                Board[Selected.tY][Selected.tX] = nil
                Selected = nil
                Board.reverse()
                return
            end
        end
        -- Switch Selected
        if pressed and pressed[1] == Selected[1] then
            Selected = pressed
        else
            -- Unfocus
            Selected = nil
        end
    elseif pressed and pressed[1] == Turn then
        Selected = pressed
    end
end
