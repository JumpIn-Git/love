function love.load()
	Object = require("classic/classic")
	Player = require("classes/player")()
end

function love.update(dt)
	Player:update(dt)
end

function love.draw()
	Player:draw()
end
