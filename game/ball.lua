return function(x, y, radius)
    local d =
    {
        x = x,
        y = y,
        radius = radius,
        speed = {
            x = 200,
            y = 20,
        },
        spinRate = 100,
        rotation = 0,
    }
    d.angularVelocity = function() return d.spinRate / radius end
    return d
end
