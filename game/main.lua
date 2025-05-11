require('debugger')
local Ball = require('ball')
local U = require('utils')
local mainBall = Ball(BASE_W / 2, BASE_H / 2, BASE_H / 48)
local font = love.graphics.newFont('fonts/JetBrainsMono-Regular.ttf')

love.load = function()
    love.graphics.setFont(font)
    BallImg = love.graphics.newImage("sprite/coloredBall.png")

    GameCanvas = love.graphics.newCanvas(BASE_W, BASE_H)

    love.graphics.setDefaultFilter('nearest', 'nearest')
end

local walls = {
    { normal = { x = 1, y = 0 },  pos = 0 },      -- LEFT WALL
    { normal = { x = -1, y = 0 }, pos = PHYS_W }, -- RIGHT WALL
    { normal = { x = 0, y = 1 },  pos = 0 },      -- TOP WALL
    { normal = { x = 0, y = -1 }, pos = PHYS_H }, -- BOTTOM WALL
}

local function calculateBounce(ball, wallNormal)
    -- rotate wallNormal 90 degrees CW to get the tanget vector
    local wallTangent = { x = -wallNormal.y, y = wallNormal.x }
    -- scalar Velocity
    local normalVelocity = U.scalarProduct(ball.speed, wallNormal)
    local tangentVelocity = U.scalarProduct(ball.speed, wallTangent)
    -- Decompose velocity into components
    local ballNormal = { x = wallNormal.x * normalVelocity, y = wallNormal.y * normalVelocity };
    local ballTangent = { x = wallTangent.x * tangentVelocity, y = wallTangent.y * tangentVelocity };

    -- Recombine velocity components
    ball.speed.x = -ballNormal.x + ballTangent.x
    ball.speed.y = -ballNormal.y + ballTangent.y
end

local function checkCollision(ball)
    for _, wall in ipairs(walls) do
        local dx = ball.x - wall.pos
        local dy = ball.y - wall.pos
        local distance = dx * wall.normal.x + dy * wall.normal.y

        if distance < ball.radius then
            local correction = ball.radius - distance
            ball.x = ball.x + (wall.normal.x * correction)
            ball.y = ball.y + (wall.normal.y * correction)

            calculateBounce(ball, wall.normal)
        end
    end
end


local function printDebugInfo()
    love.graphics.setColor(1, 1, 1)
    local output = string.format('speed: %d %d, spin: %d, rotation: %d', mainBall.speed.x, mainBall.speed.y,
        mainBall.angularVelocity(), mainBall.rotation * 180 / math.pi)
    love.graphics.print(output, 100, 100)
end

local spinDecay = 0.20 -- percent per second
love.update = function(dt)
    checkCollision(mainBall)
    mainBall.x = mainBall.x + mainBall.speed.x * dt
    mainBall.y = mainBall.y + mainBall.speed.y * dt
    mainBall.rotation = mainBall.rotation + mainBall.angularVelocity() * dt
    mainBall.rotation = mainBall.rotation % (math.pi * 2)
    mainBall.spinRate = mainBall.spinRate - (mainBall.spinRate * spinDecay * dt)
end

local function circleWithoutCopying(radius)
    local circleCanvas = love.graphics.newCanvas(radius * 2, radius * 2)
    love.graphics.setCanvas(circleCanvas)
    love.graphics.circle("fill", radius, radius, radius)
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(-radius, radius, radius * 2, radius)
    return circleCanvas
end

love.draw = function()
    local ballCanvas = circleWithoutCopying(mainBall.radius)
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(BallImg, mainBall.x, mainBall.y, mainBall.rotation, 1, 1
    , mainBall.radius -- ox
    , mainBall.radius -- oy
    )

    -- -- Screen walls
    -- love.graphics.setLineWidth( 20 )
    -- love.graphics.rectangle('line', 0, 0, BASE_W, BASE_H)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(GameCanvas, 0, 0, 0, DISPLAY_SCALE, DISPLAY_SCALE)

    printDebugInfo()
end
