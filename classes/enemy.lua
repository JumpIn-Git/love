local M = Object:extend()

function M:new()
	self.image = love.graphics.newImage("assets/snake.png")
	self.width, self.height = self.image:getWidth(), self.image:getHeight()
	self.x = 0
	self.y = love.graphics.getHeight() - self.width
	self.speed = 250
end

function M:update(dt)
	self.x = self.x + self.speed * dt
	if self.x < 0 then
		self.x, self.speed = -self.x, -self.speed
	elseif self.x + self.width > love.graphics.getWidth() then
		local overflow = self.x + self.width - love.graphics.getWidth()
		self.x = self.x - overflow
		self.speed = -self.speed
	end
end

function M:draw()
	love.graphics.draw(self.image, self.x, self.y)
end

return M
