local function pointDifference(p1, p2)
    return { x = p1.x - p2.x, y = p1.y - p2.y }
end

local function crossProduct(p1, p2)
    return p1.x * p2.y - p1.y * p2.x
end

local function segmentsOverlap(A1, A2, B1, B2)
    -- direction vectors
    local v1 = pointDifference(A2, A1)
    local v2 = pointDifference(B2, B1)
    local w = pointDifference(B1, A1)

    -- cross products
    local crossV1V2 = crossProduct(v1, v2)
    local crosswV1 = crossProduct(w, v1)
    local crosswV2 = crossProduct(w, v2)

    -- check if parallel
    if math.abs(crossV1V2) < 1e-10 then
        return false, nil, nil
    end

    local s = crosswV1 / crossV1V2
    local t = crosswV2 / crossV1V2

    if s < 1 and s > 0 and t < 1 and t > 0 then
        local intersection = {
            x = A1.x + (t * v1.x),
            y = A1.y + (t * v1.y),
        }
        return true, intersection, t
    end

    return false, nil, nil
end

return function(ball, line, dt)
    local ballStart = { x = ball.x, y = ball.y }
    local ballEnd = { x = ball.x + (ball.speed.x * dt), y = ball.y + (ball.speed.y * dt) }
    local overlap, intersection, t = segmentsOverlap(ballStart, ballEnd, line[1], line[2])
    return overlap, intersection, t
end
