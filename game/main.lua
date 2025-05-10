require('const')
require('debugger')
local Ball = require('ball')
local mainBall = Ball(PHYS_W / 2, PHYS_H / 2, PHYS_W / 100)

love.load = function()
    GameCanvas = love.graphics.newCanvas(BASE_W, BASE_H)

    love.graphics.setDefaultFilter("nearest", "nearest")
end

local function newPosition(ball, dt)
    local newX = ball.x + ball.speed.x * dt
    local newY = ball.y + ball.speed.y * dt

    return {
        x = newX,
        y = newY,
    }
end

love.update = function(dt)
    local newPos = newPosition(mainBall, dt)

    if newPos.x - mainBall.radius < 0 or newPos.x + mainBall.radius > PHYS_W then
        mainBall.speed.x = -mainBall.speed.x
        newPos.x = mainBall.x + mainBall.speed.x * dt
    end

    if newPos.y - mainBall.radius < 0 or newPos.y + mainBall.radius > PHYS_H then
        mainBall.speed.y = -mainBall.speed.y
        newPos.y = mainBall.y + mainBall.speed.y * dt
    end

    -- update position
    mainBall.x = newPos.x
    mainBall.y = newPos.y
end

love.draw = function()
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear()

    -- -- Screen walls
    -- love.graphics.setLineWidth( 20 )
    -- love.graphics.rectangle("line", 0, 0, BASE_W, BASE_H)

    -- ball
    love.graphics.circle("fill"
    , mainBall.x / PHYSICS_SCALE
    , mainBall.y / PHYSICS_SCALE
    , mainBall.radius / PHYSICS_SCALE)

    love.graphics.setCanvas()
    love.graphics.draw(GameCanvas, 0, 0, 0, DISPLAY_SCALE, DISPLAY_SCALE)
end
