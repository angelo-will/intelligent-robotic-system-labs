-- Put your global variables here

LOW_VELOCITY = 5
MEDIUM_VELOCITY = 10
MAX_VELOCITY = 15
QUANTUM_STEPS = 25
local n_steps = 0

FRONTAL_LIGHT_SENSORS = {1,2,23,24}
ALL_FRONTAL_SENSORS = {1,2,3,4,5,6,24,23,22,21,20,19,18}
LEFT_SENSORS = {1,2,3,4,5,6,7,8,9,10,11,12}
RIGHT_SENSORS = {13,14,15,16,17,17,18,19,20,21,22,23,24}

LIGHT_THRESHOLD = 0.3
MINIMUM_DISTANCE_OBSTACLES = 0.3

local light_reached

-- Counter used to avoid that robot will be stucked
local avoiding_counter = require("counter")

--This function is executed every time you press the 'execute' 
function init()
	avoiding_counter:reset(0,QUANTUM_STEPS)
	light_reached = false
	n_steps = 0
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
end

function step()
	
	n_steps = n_steps + 1
	if counter_not_exist_or_is_end(avoiding_counter) and not light_reached then
		left_v,right_v = wander_behaviour(robot,MAX_VELOCITY,false,n_steps,left_v,right_v)
	end
	if counter_not_exist_or_is_end(avoiding_counter) and not light_reached then 
		light_reached,left_v,right_v = phototaxis_behaviour(robot,left_v,right_v)
	end
	if not light_reached then left_v,right_v =
		 obstacle_avoidance_behaviour(robot,left_v,right_v,avoiding_counter)
	end
	log("left_v: " .. tostring(left_v))
	log("right_v: " .. tostring(right_v))
	robot.wheels.set_velocity(left_v,right_v)

end

-- This function is executed every time you press the 'reset'
-- button in the GUI. It is supposed to restore the state
-- of the controller to whatever it was right after init() was
-- called. The state of sensors and actuators is reset
-- automatically by ARGoS.
function reset()
	avoiding_counter:reset()
	light_reached = false
	n_steps = 0
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
end

-- This function is executed only once, when the robot is removed
-- from the simulation
function destroy()
end

-- Behaviour of a robot that try to avoid obstacle.
-- Return speed of wheels to avoid but if no object is detected return same speeds passed.
-- Counter is used to get far away from an object before do other actions.
function obstacle_avoidance_behaviour(robot,default_left_v,default_right_v,counter)
	local obs_idx, obs_max = detect_max_sensor_value(robot.proximity)

	log("OA - obs_idx = " .. tostring(obs_idx))
	log("OA - obs_max = " .. tostring(obs_max))
	if obs_idx and contains(ALL_FRONTAL_SENSORS,obs_idx) 
		and obs_max >= MINIMUM_DISTANCE_OBSTACLES then
		-- object is in front
		log("OA - See an object")
		counter:reset(counter:get_initial(),robot.random.uniform(2,QUANTUM_STEPS))
		counter:tick()
		log("OA - counter:get_count() = " .. counter:get_count())
		if random_boolean() then 
			return turn_right(MEDIUM_VELOCITY)
		else
			return turn_right(MEDIUM_VELOCITY)
		end
	elseif not counter:is_init() then
		-- i have already been avoiding
		counter:tick()
		if counter:is_end() then counter:reset() end
		return go_forward(MEDIUM_VELOCITY)
	else
		-- no object detected
		return default_left_v,default_right_v
	end
end

-- Behaviour of a robot that try follow a light.
-- If light is not detected speeds returned are which are passed.
-- First boolean is false if light is not reached, true otherwise.
function phototaxis_behaviour(robot,default_left_v,default_right_v)
	local light_idx, light_max = detect_max_sensor_value(robot.light)
	log("PT - sensorLight[" .. tostring(light_idx) .. "]" .. light_max)
	if light_max < LIGHT_THRESHOLD then
		if light_idx and (not contains(FRONTAL_LIGHT_SENSORS,light_idx)) then 
			-- light detected but is not positioned in front
			log("PT- See light")
			if contains(LEFT_SENSORS,light_idx) then
				return false,turn_left(MEDIUM_VELOCITY)
			else
				return false,turn_right(MEDIUM_VELOCITY)
			end
		elseif not light_idx then
			-- no light detected
			log("PT- No light detected")
			return false,default_left_v,default_right_v
		else
			-- light in front
			return false,go_forward(MAX_VELOCITY)
		end
	else
		-- light reached
		return true, stop()
	end
end

-- Return two random speed between 0 and limit (included) after total steps.
-- If steps are not passed return defaults speed passed
-- If single_wheel is true only one speed is returned.
function wander_behaviour(robot,limit,single_wheel,steps,default_left_v,default_right_v)
	if n_steps_are_passed(steps, QUANTUM_STEPS) then
		log("Do wander")
		if single_wheel then
			return robot.random.uniform(0,limit)
		else
			return robot.random.uniform(0,limit),robot.random.uniform(0,limit)
		end
	else
		return default_left_v,default_right_v
	end
end

-- Return true if quantum_steps are passed in steps, false otherwise
function n_steps_are_passed(steps,quantum_steps)
	return steps % quantum_steps == 0
end

-- Return true if counter not exist or is ended, false otherwise
function counter_not_exist_or_is_end(counter)
	return not counter or counter:is_init()
end

-- Passed a sensors array return index of them with highest value and the value.
-- nil,0 otherwise
function detect_max_sensor_value(sensors)
	local idx = nil
	local max = 0
	for i=1,#sensors do
		if sensors[i].value > max then
			idx = i
			max = sensors[i].value
		end
	end
	return idx,max

end

-- Return true if table contains element, false otherwise
function contains(table, element)
	for _,value in ipairs(table)
	do
		if value == element then
			return true
		end
	end
	return false
end

-- Return two speed to turn left a footbot 
function turn_left(speed)
	return -speed,speed	
end

-- Return two speed to turn right a footbot 
function turn_right(speed)
	return speed,-speed	
end

-- Return two speed equal to passed speed
function go_forward(speed)
	return speed,speed
end

-- Return two stop speed
function stop()
	return 0,0
end

-- Function to get a random boolean 
function random_boolean()
	math.randomseed(os.time())
	return (math.random(1, 2) % 2) == 0
end

