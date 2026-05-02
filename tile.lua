Pawn, Horse, Tower, Bishop, King, Queen = 1, 2, 3, 4, 5, 6

Black = {}
Black.img = love.graphics.newImage("tiles/16x16 pieces/BlackPieces.png")
Black.img:setFilter('nearest', 'nearest')
for i = 0, 6 do
    table.insert(Black, love.graphics.newQuad(16 * i, 0, 16, 16, Black.img))
end

White = {}
White.img = love.graphics.newImage("tiles/16x16 pieces/WhitePieces.png")
White.img:setFilter('nearest', 'nearest')
for i = 0, 6 do
    table.insert(White, love.graphics.newQuad(16 * i, 0, 16, 16, White.img))
end
