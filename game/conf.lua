require('const')
-- _G.inspect = function(value) require('inspect')(value) end
_G.inspect = require('inspect')

function love.conf(t)
    t.window.width = SCREEN_W
    t.window.height = SCREEN_H
end
