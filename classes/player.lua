local M = Object:extend()

function M:new()
	self.image = love.graphics.newImage("assets/panda.png")
	self.width = self.image:getWidth()
	self.x = love.graphics.getWidth() / 2 - self.width / 2
	self.y = 0
	self.speed = 320
end

function M:update(dt)
	if love.keyboard.isDown("left") then
		self.x = self.x - self.speed * dt
	end
	if love.keyboard.isDown("right") then
		self.x = self.x + self.speed * dt
	end

	if self.x < 0 then
		self.x = 0
	end
	if self.x + self.width > love.graphics.getWidth() then
		self.x = love.graphics.getWidth() - self.width
	end
end

function M:draw()
	love.graphics.draw(self.image, self.x, self.y)
end

return M
