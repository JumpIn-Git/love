-- Work with scaling
local Offset = Offset * 5
local Tile = Tile * 5
local function mouseToTile(x, y)
    if x <= 6 * 5 or x >= 135 * 5 or y <= 6 * 5 or y >= 135 * 5 then
        return nil, nil -- Out of bounds
    end
    return math.floor((x - Offset) / Tile) + 1, math.floor((y - Offset) / Tile) + 1
end
function love.mousepressed(x, y, b)
    if b ~= 1 or Gameover then
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
                -- Check if killing king
                if pressed ~= nil and pressed[2] == King then
                    Gameover = true
                    Winner = Selected[1]
                end
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
        -- Not selected anything yet
    elseif pressed and pressed[1] == Turn then
        Selected = pressed
        Selected.tX, Selected.tY = x, y
        Selected.canMoveTo = Logic[Selected[2]](Selected, Selected.tX, Selected.tY)
    end
end
