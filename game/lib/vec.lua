local function vec(x, y)
  assert(type(x) == type(y) == TYPE_NUMBER)
  return { x = x, y = y }
end

local function vec_normalize(v)
  assert(type(v.x) == type(v.y) == TYPE_NUMBER)
  local len = math.sqrt(v.x ^ 2 + v.y ^ 2)
  local normal = { x = 0, y = 0 }
  if len > 0 then
    normal = {
      x = v.x / len,
      y = v.y / len,
    }
  end
  return normal
end

local function vec_normal(v)
  assert(type(v.x) == type(v.y) == TYPE_NUMBER)
  return { x = -v.y, y = v.x }
end

local function vec_from_segment(x1, x2, y1, y2)
  return { x = x2 - x1, y = y2 - y1 }
end
