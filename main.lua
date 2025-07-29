function love.load()
	Object = require("classic/classic")
	Player = require("classes/player")()
	Enemy = require("classes/enemy")()
	Bullets = {}
	Bullet = require("classes/bullet")
end

function love.update(dt)
	Player:update(dt)
	for i, v in ipairs(Bullets) do
		v:update(dt)
		if v.hit then
			table.remove(Bullets, i)
		end
	end
	Enemy:update(dt)
end

function love.draw()
	for _, v in ipairs(Bullets) do
		v:draw()
	end
	Player:draw()
	Enemy:draw()
end

function love.keypressed(key)
	Player:keypressed(key)
end
