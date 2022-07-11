Player = {
    canJump=false,
    collider=nil,
    img=nil,
    size={}
}

function Player:new (o, x, y, width, height, src)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.img = love.graphics.newImage(src)
    self.size = {width, height}
    
    self.collider = world:newRectangleCollider(x, y, width, height)
    self.collider:setCollisionClass("player")
    self.collider:setRestitution(0.1)
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)
    
    return o
end

function Player:update(dt)
    self.collider:setX(self.collider:getX()+2.5)
    
    if self.collider:enter("danger") then
        love.event.quit("restart")
    end
end

function Player:draw()
    love.graphics.draw(
        self.img,
        self.collider:getX()-(self.size[1]/2),
        self.collider:getY()-(self.size[2]/2),
        nil, 1, 1
    )
end

return{Player=Player}
