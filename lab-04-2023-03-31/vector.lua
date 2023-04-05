-- aaaaa
local vector = {}

-- Summing all 2D vector in array
function vector.vec2_sum_multiple_cart(vectors_array)
	local vector_sum = {x=0,y=0}
	for i=0,#vectors_array do
		vector_sum = vector.vec2_sum(vector_sum,vectors_array[i])
	end
	return vector_sum
end

-- Summing two 2D vectors in cartesian coordinates
function vector.vec2_sum(v1, v2)
	local v3 = {x = 0 , y = 0}
	v3.x = v1.x + v2.x
	v3.y = v1.y + v2.y
	return v3
end

-- Return a polar vector with length and angle passed
function vector.build_polar(length,angle)
	return {length = length, angle=angle}
end

-- From polar to cartesian coordinates
function vector.polar_to_cart(v)
	local z = 
	{x = v.length * math.cos(v.angle),
	 y = v.length * math.sin(v.angle)}
	return z
end

-- Getting the angle of a 2D vector
function vector.vec2_angle(v)
	return math.atan2(v.y, v.x)
end

-- Getting the length of a 2D vector
function vector.vec2_length(v)
	return math.sqrt(math.pow(v.x,2) + math.pow(v.y,2))
end

-- From cartesian to polar coordinates
function vector.cart_to_polar(v)
	local z = 
		{
			length = vector.vec2_length(v),
			angle = vector.vec2_angle(v)
		}
	return z
end

-- Setting a 2D vector from length and angle
function vector.vec2_new_polar(length, angle)
   local vec2 = 
		{
      		x = length * math.cos(angle) ,
      		y = length * math.sin(angle)
   		}
   return vec2
end

-- Multiple polar vector v lenght for a factor scale
function vector.polar_scale(v,scale)
	return vector.build_polar(v.length*scale,v.angle)
end

-- Return a polar vecto with lenght and angle zero
function vector.polar_zero()
	return vector.build_polar(0,0)
end

-- Return true if length of passed polar vector is zero
function vector.is_polar_len_zero(v)
	return v.length == 0
end

-- Return 2D vector opposite to vector v passed
function vector.vect2_cart_opposite(v)
	return {x = -v.x, y=-v.y}
end

-- Return a polar vector opposite to v passed 
function vector.polar_opposite(v)
	return vector.cart_to_polar(vector.vect2_cart_opposite(
		vector.polar_to_cart(v)))
end

-- Return a string representative the vector passed both polar and cartesian
function vector.tostring(v)
	if (v.x and v.y) then return tostring("{x="..v.x..",y="..v.y.."}")
	elseif (v.length and v.angle) then 
		return tostring("{length="..v.length..",angle="..v.angle.."}")
	end
end

-- Summing two 2D vectors in polar coordinates
function vector.vec2_polar_sum(v1, v2)
	local w1 = vector.polar_to_cart(v1)
	local w2 = vector.polar_to_cart(v2)
	local w3 = vector.vec2_sum(w1,w2)
	local v3 = vector.cart_to_polar(w3)
	return v3
end

return vector
