return {
  new = function(x, y)
    assert(type(x) == TYPE_NUMBER, "param x = " .. type(x))
    assert(type(y) == TYPE_NUMBER, "param y = " .. type(x))
    return { x = x, y = y }
  end,

  normalize = function(v)
    assert(type(v.x) == TYPE_NUMBER)
    assert(type(v.y) == TYPE_NUMBER)
    local len = math.sqrt(v.x ^ 2 + v.y ^ 2)
    local normal = { x = 0, y = 0 }
    if len > 0 then
      normal = {
        x = v.x / len,
        y = v.y / len,
      }
    end
    return normal
  end,

  normal = function(v)
    assert(type(v.x) == TYPE_NUMBER)
    assert(type(v.y) == TYPE_NUMBER)
    return { x = -v.y, y = v.x }
  end,

  from_segment = function(x1, x2, y1, y2)
    return { x = x2 - x1, y = y2 - y1 }
  end,
}
