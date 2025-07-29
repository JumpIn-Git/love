function love.load()
	Object = require("classic/classic")
	Player = require("classes/player")()
	Enemy = require("classes/enemy")()
end

function love.update(dt)
	Player:update(dt)
	Enemy:update(dt)
end

function love.draw()
	Player:draw()
	Enemy:draw()
end
