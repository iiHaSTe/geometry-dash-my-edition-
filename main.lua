-- graphics
local spritesPath = "assets/sprites/"
local backgroundsPath = "assets/bg/"

function love.load()
    -- global requires
    wf = require 'lib/windfield'
    cam = require('lib/hump/camera')(width()/2, height()/2)
    sti = require 'lib/sti/sti'
    
    -- game classes
    Player = require("player").Player
    
    -- setup
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.physics.setMeter(32)
    
    world = wf.newWorld(0, 0, true)
    world:setGravity(0, 512)
    world:setQueryDebugDrawing(false)
    collisionClasses = {"solid", "player", "ground", "danger"}
    for _, i in pairs(collisionClasses) do
        world:addCollisionClass(i)
    end
    
    -- camera settings
    cam:zoom(1.7)
    
    -- map
    map = sti('map/main.lua', { "box2d" })
    
    -- background
    bg = love.graphics.newImage(backgroundsPath.."main.jpeg")
    
    -- game objects
    player = Player:new(nil, 100, 500, 33, 30, spritesPath.."player.png")
    
    dangers = {}
    if map.layers["spicks"] then
        for i, danger in pairs(map.layers["spicks"].objects) do
            local d = world:newRectangleCollider(danger.x, danger.y, danger.width, danger.height)
            d:setCollisionClass("danger")
            d:setType("static")
            table.insert(danger, d)
        end
    end
    
    grounds = {}
    if map.layers["ground"] then -- add collision box for all grounds
        for i, ground in pairs(map.layers["ground"].objects) do
            local g = world:newRectangleCollider(ground.x, ground.y, ground.width, ground.height)
            g:setCollisionClass("ground")
            g:setType("static")
            table.insert(grounds, g)
        end
    end
end

function love.update(dt)
    if player.collider:enter("ground") or player.collider:enter("solid") then
        player.canJump = true
    end
    cam:lookAt(player.collider:getX(), player.collider:getY())
    
    local p = 120
    if cam.y < (height()/2)-p then
        cam.y = (height()/2)-p
    end
    if cam.x < (width()/2)-p then
        cam.x = (width()/2)-p
    end
    
    map:update(dt)
    player:update(dt)
    world:update(dt)
end

function love.draw()
    love.graphics.draw(
        bg, 0, 0,
        nil, 3.1, 2
    )
    cam:attach()
	    map:drawLayer(map.layers["main"])
        world:draw()
        player:draw()
    cam:detach()
end

function catch(what)
    return what[1]
end
function try(what)
    status, result = pcall(what[1])
    if not status then
        what[2](result)
    end
    return result
end
function getTableLng(tbl)
    local getN = 0
    for n in pairs(tbl) do 
        getN = getN + 1 
    end
    return getN
end
function love.mousepressed( x, y, button, istouch, presses )
    if button==1 and player.canJump then
        player.collider:applyLinearImpulse(0, -500)
        player.canJump = false
    end
end
function width()
    return love.graphics.getWidth()
end
function height()
    return love.graphics.getHeight()
end
