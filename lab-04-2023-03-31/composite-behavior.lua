-- Put your global variables here

LOW_VELOCITY = 5
MEDIUM_VELOCITY = 10
MAX_VELOCITY = 15
QUANTUM_STEPS = 15
local n_steps = 0

LIGHT_THRESHOLD = 0.31
MINIMUM_DISTANCE_OBSTACLES = 0.2

DEBUG = true

local vl = require "vector"
local v_tstr = vl.tostring

local ts = tostring

local light_found
local light_reached
local light_variation
local obs_detected

local wd_pol_vec

local velocity

-- Function to set initial parameters of simulation
function initialize_simulation()
	light_found = false
	light_reached = false
	obs_detected = false
	n_steps = 0
	light_variation = 0
	wd_pol_vec = vl.build_polar(get_random_velocity_and_angle())
	velocity = wd_pol_vec
	robot.wheels.set_velocity(get_speed_from_velocity(velocity))
end

--This function is executed every time you press the 'execute' 
function init()
	initialize_simulation()
end

function reset()
	initialize_simulation()
end

function step()
	n_steps = n_steps + 1
	local pt_pol_vec = vl.polar_zero()
	local oa_pol_vec = vl.polar_zero()
	velocity = vl.polar_zero()

	oa_pol_vec = (not light_reached) and obstacle_avoidance_behaviour() or vl.polar_zero()
	pt_pol_vec = phototaxis_behaviour()
	wd_pol_vec = not light_reached and wander_behaviour(wd_pol_vec) or vl.polar_zero()

	debug_log("PT-velocity="..v_tstr(pt_pol_vec))
	debug_log("OA-velocity="..v_tstr(oa_pol_vec))
	debug_log("WD-velocity="..v_tstr(wd_pol_vec))

	oa_pol_vec = vl.polar_scale(oa_pol_vec,10)
	pt_pol_vec = vl.polar_scale(pt_pol_vec,obs_detected and MEDIUM_VELOCITY or MAX_VELOCITY)
	wd_pol_vec = vl.polar_scale(wd_pol_vec, (obs_detected or light_found) and 0.1 or 1)

	debug_log("PT-velocity-after-scale="..v_tstr(pt_pol_vec))
	debug_log("OA-velocity-after-scale="..v_tstr(oa_pol_vec))
	debug_log("WD-velocity-after-scale="..v_tstr(wd_pol_vec))

	velocity = vl.vec2_polar_sum(velocity,pt_pol_vec)
	debug_log("vel+pt="..v_tstr(velocity))

	velocity = vl.vec2_polar_sum(velocity,oa_pol_vec)
	debug_log("vel+oa="..v_tstr(velocity))

	velocity = vl.vec2_polar_sum(velocity,wd_pol_vec)
	debug_log("vel+wd="..v_tstr(velocity))


	local left_v,right_v = get_speed_from_velocity(velocity)

	-- if light_found and not obs_detected then
	-- 	left_v,right_v = normalize_speeds_to_max(left_v,right_v)
	-- end

	debug_log("speeds: left_v="..left_v..",right_v="..right_v)

	left_v,right_v = normalize_speeds_to_medium(left_v,right_v)

	debug_log("speeds normalized: left_v="..left_v..",right_v="..right_v)

	robot.wheels.set_velocity(left_v,right_v)

end

-- Normalize two speed passed if one of them is over the limit passed,
-- in that case return highest speed equal to limit and other proportional
-- to it.
function normalize_speeds_to(left_v,right_v,speeds_limit) 
	if left_v >speeds_limit or right_v > speeds_limit then
		if left_v > right_v then
			right_v = (speeds_limit*right_v)/left_v
			left_v = speeds_limit
		else
			left_v = (speeds_limit*left_v)/right_v
			right_v = speeds_limit
		end
	end
	return left_v,right_v
end

-- Normalize two speed proportional to MAX_VELOCITY
function normalize_speeds_to_max(left_v,right_v)
	return normalize_speeds_to(left_v,right_v,MAX_VELOCITY)
end

-- Normalize two speed proportional to MEDIUM_VELOCITY
function normalize_speeds_to_medium(left_v,right_v)
	return normalize_speeds_to(left_v,right_v,MEDIUM_VELOCITY)
end

-- Normalize two speed proportional to LOW_VELOCITY
function normalize_speeds_to_low(left_v,right_v)
	return normalize_speeds_to(left_v,right_v,LOW_VELOCITY)
end

-- Calculate left and right speed wheels of robot based on velocity passed.
-- Velocity has to have length and angle parameters
function get_speed_from_velocity(velocity)
	local wheels_distance = robot.wheels.axis_length
	local left_v = velocity.length - (velocity.angle*wheels_distance)/2
	local right_v = velocity.length + (velocity.angle*wheels_distance)/2

	return left_v,right_v
end

-- This function is executed every time you press the 'reset'
-- button in the GUI. It is supposed to restore the state
-- of the controller to whatever it was right after init() was
-- called. The state of sensors and actuators is reset
-- automatically by ARGoS.

-- This function is executed only once, when the robot is removed
-- from the simulation
function destroy()
end

-- Perform obstacle avoidance behaviour returning a polar vector
-- indicating movement of robot reverse to obstacles perceived.
function obstacle_avoidance_behaviour()
	
	local max,obs_vec_sum = sensors_values_as_vector(robot.proximity)
	obs_detected = max > MINIMUM_DISTANCE_OBSTACLES

	-- debug_log("OA-obs_detected="..ts(obs_detected))
	debug_log("OA-max="..ts(max))
	debug_log("OA-Vector polar sum: " .. v_tstr(obs_vec_sum))
	local opposite_vector = vl.polar_opposite(obs_vec_sum)
	-- debug_log("OA-Vector opposite: " .. v_tstr(opposite_vector))
	return opposite_vector
end

-- Perform phototaxis behaviour returning a polar vector
-- indicating movement of robot toward the light. The vector is equal to zero if 
-- light is reache or if no light is found.
function phototaxis_behaviour()
	
	local max,light_vec_sum = sensors_values_as_vector(robot.light)
	light_found = max > 0
	light_reached = max > LIGHT_THRESHOLD

	-- debug_log("PT-max="..max)
	-- debug_log("new_max-old_max="..ts(max-light_variation))
	-- debug_log("PT-light_found="..ts(light_found))
	-- debug_log("PT-Vector polar sum: " .. v_tstr(light_vec_sum))
	light_variation = max
	return light_reached and vl.polar_zero() or light_vec_sum
end

-- Perform a wander behaviour returning a polar vector toward random direction.
-- If QUANTUM_STEPS of simulation are not passed, return velocity vector passed.
function wander_behaviour(velocity)
	if n_steps_are_passed(n_steps, QUANTUM_STEPS) then
		return vl.build_polar(get_random_velocity_and_angle())
	else
		return velocity
	end
end

-- Return max of values perceived by sensors and a sum of values as polar vector
-- based on position of each sensors.
function sensors_values_as_vector(sensors)
	local max = 0
	local vectors_sum = vl.polar_zero()
	for i=1,#sensors do
		local vector_polar =
		{
			length = sensors[i].value,
			angle = sensors[i].angle
		}
		vectors_sum = vl.vec2_polar_sum(vectors_sum,vector_polar)
		max = sensors[i].value > max and sensors[i].value or max
	end
	return max,vectors_sum
end

-- Return speed and angle randomly
function get_random_velocity_and_angle()
	local speed = robot.random.uniform(MEDIUM_VELOCITY,MAX_VELOCITY)
	local angle = get_radians_robot_angle(robot.random.uniform(0,180)-90)
	return speed,angle
end

function get_radians_robot_angle(angle_degrees)
	return angle_degrees < 180 and math.rad(angle_degrees) or math.rad(angle_degrees-360)
end
-- Return true if quantum_steps are passed in steps, false otherwise
function n_steps_are_passed(steps,quantum_steps)
	return steps % quantum_steps == 0
end

function debug_log(string)
	if DEBUG then
		log(string)
	end
end

