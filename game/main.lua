require('debugger')
local Ball = require('ball')
local U = require('utils')
require 'pl'
local mainBall = Ball(PHYS_W / 2, PHYS_H / 2, PHYS_W / 50)
local font = love.graphics.newFont('fonts/JetBrainsMono-Regular.ttf')

local walls = {
    { normal = { x = 1, y = 0 },  pos = 0 },      -- LEFT WALL
    { normal = { x = -1, y = 0 }, pos = PHYS_W }, -- RIGHT WALL
    { normal = { x = 0, y = 1 },  pos = 0 },      -- TOP WALL
    { normal = { x = 0, y = -1 }, pos = PHYS_H }, -- BOTTOM WALL
}

local function testMovement(ball, wallNormal)
    -- rotate wallNormal 90 degrees CW to get the tanget vector
    local wallTangent = { x = -wallNormal.y, y = wallNormal.x }
    -- scalar Velocity
    local normalVelocity = U.scalarProduct(ball.speed, wallNormal)
    local tangentVelocity = U.scalarProduct(ball.speed, wallTangent)
    -- Decompose velocity into components
    local ballNormal = { x = wallNormal.x * normalVelocity, y = wallNormal.y * normalVelocity };
    local ballTangent = { x = wallTangent.x * tangentVelocity, y = wallTangent.y * tangentVelocity };

    -- Contact point velocity relative to wall
    -- local contactVel = tangentVelocity + ball.spinRate;

    -- Calculate impulse (friction effect)
    local restitution = 1 -- Coefficient of restitution
    -- local friction = 0.2  -- Coefficient of friction
    -- local mass = 1
    -- local impulse = friction * (1 + restitution) * mass * math.abs(normalVelocity)

    -- Apply impulse effects based on contact velocity direction
    -- local impulseFactor
    -- if contactVel > 0 then
    --     impulseFactor = -impulse
    -- elseif contactVel < 0 then
    --     impulseFactor = impulse
    -- end

    -- Reflect normal velocity component
    local newBallNormal = { x = -restitution * ballNormal.x, y = -restitution * ballNormal.y };

    -- Apply friction to tangential velocity
    local newBallTangent = {
        x = ballTangent.x,
        y = ballTangent.y,
    }

    -- -- Update angular velocity (torque effect)
    -- local momentOfInertia = 0.4 * mass * ball.radius ^ 2 -- For solid sphere
    -- local angularVelocity = ball.angularVelocity() + impulseFactor * ball.radius / momentOfInertia
    -- ball.spinRate = angularVelocity * ball.radius

    -- Recombine velocity components
    ball.speed.x = newBallNormal.x + newBallTangent.x
    ball.speed.y = newBallNormal.y + newBallTangent.y
end

local function collision(ball)
    for _, wall in ipairs(walls) do
        local dx
        local dy
        local distance

        dx = ball.x - wall.pos
        dy = ball.y - wall.pos
        distance = dx * wall.normal.x + dy * wall.normal.y

        if distance < ball.radius then
            local correction = ball.radius - distance
            ball.x = ball.x + (wall.normal.x * correction)
            ball.y = ball.y + (wall.normal.y * correction)

            testMovement(ball, wall.normal)
        end
    end
end


love.load = function()
    love.graphics.setFont(font)

    GameCanvas = love.graphics.newCanvas(BASE_W, BASE_H)

    love.graphics.setDefaultFilter('nearest', 'nearest')
end

local function printDebugInfo()
    love.graphics.setColor(1, 1, 1)
    local output = string.format('speed: %d %d, spin: %d, rotation: %d', mainBall.speed.x, mainBall.speed.y,
        mainBall.angularVelocity(), mainBall.rotation * 180 / math.pi)
    love.graphics.print(output, 100, 100)
end

local function newPosition(ball, dt)
    local newX = ball.x + ball.speed.x * dt
    local newY = ball.y + ball.speed.y * dt

    return {
        x = newX,
        y = newY,
    }
end

local function verticalBounce(x, radius)
    return x - radius < 0 or x + radius > PHYS_W
end

local function horizontalBounce(y, radius)
    return y - radius < 0 or y + radius > PHYS_H
end

local function handleVerticalBounce(ball, dt)
    local spinFactor = 0.2
    ball.speed.x = -ball.speed.x
    -- ball.speed.y = ball.speed.y + (ball.spin * ball.radius * spinFactor)
end

local function handleHorizontalBounce(ball, dt)
    local spinFactor = 0.2
    ball.speed.y = -ball.speed.y
    -- ball.speed.x = ball.speed.x + (ball.spin * ball.radius * spinFactor)
end

local function rotate(p1, p2, deg)
    local s = math.sin(deg)
    local c = math.cos(deg)

    -- p'x = cos(theta) * (px-ox) - sin(theta) * (py-oy) + ox
    -- p'y = sin(theta) * (px-ox) + cos(theta) * (py-oy) + oy

    local x = c * (p1[1] - p2[1]) - s * (p1[2] - p2[2])
    local y = s * (p1[1] - p2[1]) - c * (p1[2] - p2[2])

    return {
        x + p2[1],
        y + p2[2],
    }
end

List.apply = function(self, fun, ...)
    return List(fun(self, ...))
end

love.update = function(dt)
    collision(mainBall)
    mainBall.x = mainBall.x + mainBall.speed.x * dt
    mainBall.y = mainBall.y + mainBall.speed.y * dt
    mainBall.rotation = mainBall.rotation + mainBall.angularVelocity() * dt
    mainBall.rotation = mainBall.rotation % (math.pi * 2)
end

love.draw = function()
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear()

    -- -- Screen walls
    -- love.graphics.setLineWidth( 20 )
    -- love.graphics.rectangle('line', 0, 0, BASE_W, BASE_H)

    love.graphics.circle("fill"
    , mainBall.x / PHYSICS_SCALE
    , mainBall.y / PHYSICS_SCALE
    , mainBall.radius / PHYSICS_SCALE
    )

    local ballPos = List({ mainBall.x, mainBall.y })
    local p1 = List({ -mainBall.radius, 0 })
        :map2('+', ballPos)
        :apply(rotate, ballPos, mainBall.rotation)
        :map('/', PHYSICS_SCALE)
    local p2 = List({ mainBall.radius, 0 })
        :map2('+', ballPos)
        :apply(rotate, ballPos, mainBall.rotation)
        :map('/', PHYSICS_SCALE)
    local points = p1:extend(p2)

    love.graphics.setColor(0.2, 0, 0)
    love.graphics.setLineWidth(1)
    love.graphics.line(points)


    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(GameCanvas, 0, 0, 0, DISPLAY_SCALE, DISPLAY_SCALE)

    printDebugInfo()
end
