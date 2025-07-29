local M = Object:extend()

function M:new()
	self.image = love.graphics.newImage("assets/bullet.png")
	self.width, self.height = self.image:getWidth(), self.image:getHeight()
	self.speed = 700
	self.x, self.y = Player.x + Player.width / 2, Player.y
	self.hit = false
end

function M:checkCollision()
	local x_collide = Enemy.x < self.x and self.x + self.width < Enemy.x + Enemy.width
	local y_collide = Enemy.y < self.y and self.x + self.width < Enemy.x + Enemy.width
	if x_collide and y_collide then
		Enemy.speed = Enemy.speed + 30 * (Enemy.speed > 0 and 1 or -1)
		self.hit = true
	end
end

function M:draw()
	love.graphics.draw(self.image, self.x, self.y)
end

function M:update(dt)
	self.y = self.y + self.speed * dt
	self:checkCollision()
end

return M
