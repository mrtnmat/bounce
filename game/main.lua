require('debugger')
local vec = require('lib.vec')
local Ball = require('ball')
local U = require('utils')
local check_line_collision = require('lineCollision')
local mainBall = Ball(BASE_W / 40, BASE_H / 2, math.floor(BASE_H / 48))
local font = love.graphics.newFont('fonts/JetBrainsMono-Regular.ttf')

local function newBrick(x, y, width, height)
  return {
    x = x,
    y = y,
    width = width,
    height = height,
  }
end

local bricksList = {
  newBrick(10, 10, 30, 10),
  newBrick(50, 10, 30, 10),
  newBrick(90, 10, 30, 10),
}

local function drawBricks(bricks)
  for _, brick in ipairs(bricks) do
    love.graphics.setColor(0.8, 0.2, 0)
    love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height)
  end
end

love.load = function()
  love.graphics.setFont(font)
  BallImg = love.graphics.newImage("sprite/coloredBall.png")

  GameCanvas = love.graphics.newCanvas(BASE_W, BASE_H)

  -- love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setDefaultFilter('linear', 'nearest')

  love.mouse.setGrabbed(true)
end

local walls = {
  { normal = { x = 1, y = 0 },  pos = 0 },      -- LEFT WALL
  { normal = { x = -1, y = 0 }, pos = BASE_W }, -- RIGHT WALL
  { normal = { x = 0, y = 1 },  pos = 0 },      -- TOP WALL
  { normal = { x = 0, y = -1 }, pos = BASE_H }, -- BOTTOM WALL
}

local walls2 = {
  { { x = 0, y = 0 },      { x = BASE_W, y = 0 } },      -- TOP WALL
  { { x = BASE_W, y = 0 }, { x = BASE_W, y = BASE_H } }, -- RIGHT WALL
  -- { { x = BASE_W, y = BASE_H }, { x = 0, y = BASE_H } },      -- BOTTOM WALL
  { { x = 0, y = BASE_H }, { x = 0, y = 0 } },           -- LEFT WALL
}

local lines = {
  -- { { x = 0, y = 0, },                         { x = 180, y = 180 } },                     -- DIAGONAL WALL
  { { x = BASE_W / 2 - 20, y = BASE_H - 20, }, { x = BASE_W / 2 + 20, y = BASE_H - 20 } }, -- PADDLE
}

local function calculateBounce(ball, wallNormalOLD)
  -- rotate wallNormal 90 degrees CW to get the tanget vector
  local wallNormal = { x = -wallNormalOLD.y, y = wallNormalOLD.x }
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

  local function sign(n)
    if n == 0 then return 0 end
    if n < 0 then return -1 end
    return 1
  end

  -- Increase ball speed slightly
  local increment = (love.math.random() * 2 + 1)
  ball.speed.x = ball.speed.x + (increment * sign(ball.speed.x))
  ball.speed.y = ball.speed.y + (increment * sign(ball.speed.y))

  -- Increase spin slightly
  ball.spinRate = ball.spinRate + (love.math.random() * 15 - 4)
end

local function check_wall_collision(ball)
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

local spinDecay = 0.05 -- percent per second

local function check_all_collisions(collidables, dt)
  local collisions = {}
  for index, wall in ipairs(collidables) do
    local line_collision, intersection, t = check_line_collision(mainBall, wall, dt)
    if (line_collision) then
      table.insert(collisions, wall)
    end
  end
  return collisions
end

local function move_paddle()
  local x = love.mouse.getX() / SCALING_FACTOR
  print(inspect(lines[1]))
  lines[1][1].x = x - 20
  lines[1][2].x = x + 20
end

local function check_gameover()
  return mainBall.y > BASE_H
end

local function gameover_message()
  love.graphics.setColor(1, 0, 0)
  love.graphics.setFont(font) -- assuming you have a font set up
  local text = "GAME OVER LOSER"
  local textWidth = love.graphics.getFont():getWidth(text)
  love.graphics.print(
    text,
    love.graphics.getWidth() / 2 - (textWidth * 4) / 2,
    love.graphics.getHeight() / 2 - 20,
    0,
    4,
    4
  )
end

local state = 'playing'

love.update = function(dt)
  if check_gameover() then
    state = 'gameover'
    love.mouse.setGrabbed(false)
    return
  end
  move_paddle()
  -- check_wall_collision(mainBall)
  local collisions = check_all_collisions(walls2, dt)
  if #collisions > 0 then
    local n1 = vec.from_segment(collisions[1][1], collisions[1][2])
    local n2 = vec.normalize(n1)
    calculateBounce(mainBall, n2)
  end
  collisions = check_all_collisions(lines, dt)
  if #collisions > 0 then
    local n1 = vec.from_segment(collisions[1][1], collisions[1][2])
    local n2 = vec.normalize(n1)
    calculateBounce(mainBall, n2)
  end
  -- local line_collision, intersection, t = check_line_collision(mainBall, line, dt)
  -- if line_collision then
  --     local n1 = vec.from_segment(unpack(line))
  --     print(inspect(n1))
  --     local n2 = vec.normalize(n1)
  --     print(inspect(n2))
  --     local coll = calculateBounce(mainBall, n2)
  --     print(inspect(coll))
  -- end
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
  if state == 'gameover' then
    gameover_message()
  else
    local ballCanvas = circleWithoutCopying(mainBall.radius)
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(ballCanvas, mainBall.x, mainBall.y, mainBall.rotation, 1, 1
    , mainBall.radius -- ox
    , mainBall.radius -- oy
    )

    for _, line in ipairs(lines) do
      love.graphics.line(line[1].x, line[1].y, line[2].x, line[2].y)
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(GameCanvas, 0, 0, 0, DISPLAY_SCALE, DISPLAY_SCALE)
  end


  -- -- Screen walls
  -- love.graphics.setLineWidth( 20 )
  -- love.graphics.rectangle('line', 0, 0, BASE_W, BASE_H)
  -- drawBricks(bricksList)


  printDebugInfo()
end
