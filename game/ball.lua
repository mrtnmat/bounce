return function(x, y, radius)
    local spinRate = 100
    return {
        x = x,
        y = y,
        radius = radius,
        speed = {
            x = 800,
            y = 000,
        },
        spinRate = spinRate,
        angularVelocity = function() return spinRate / radius end,
        rotation = 0
    }
end