local function normalizeVector(vector)
    local l = math.sqrt(vector.x ^ 2 + vector.y ^ 2)
    if l == 0 then return { x = 0, y = 0 } end
    return {
        x = vector.x / l,
        y = vector.y / l,
    }
end

local function scalarProduct(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

return {
    normalizeVector = normalizeVector,
    scalarProduct = scalarProduct,
}
