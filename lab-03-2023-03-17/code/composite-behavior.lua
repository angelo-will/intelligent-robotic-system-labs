-- Put your global variables here

LOW_VELOCITY = 5
MEDIUM_VELOCITY = 10
MAX_VELOCITY = 15
QUANTUM_STEPS = 25
n_steps = 0

FRONTAL_LIGHT_SENSORS = {1,2,23,24}
ALL_FRONTAL_SENSORS = {1,2,3,4,5,6,24,23,22,21,20,19,18}
LEFT_SENSORS = {1,2,3,4,5,6,7,8,9,10,11,12}
RIGHT_SENSORS = {13,14,15,16,17,17,18,19,20,21,22,23,24}

MINIMUM_DISTANCE_OBSTACLES = 0.3

-- behaviours
OBSTACLE_AVOIDANCE = 0
PHOTOTAXIS = 1

-- local avoiding_counter = require("counter")
local avoiding_counter = {}
avoiding_counter.limit = QUANTUM_STEPS
avoiding_counter.initial = 0
avoiding_counter.count = 0
function avoiding_counter:tick() 
	self.count = self.count + 1
end
function avoiding_counter:reset(start,finish)
	self.count = default or self.initial
end
function avoiding_counter:is_end()
	return self.count >= self.limit
end
function avoiding_counter:get_count()
	return self.count
end
function avoiding_counter:get_initial()
	return self.initial
end
function avoiding_counter:is_init()
	return self.count == self.initial
end

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	avoiding_counter:reset()
	n_steps = 0
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
end

function step()
	
	n_steps = n_steps + 1
	if counter_not_exist_or_is_end(avoiding_counter) then
		log("Try wander")
		left_v,right_v = wander_behaviour(robot,MAX_VELOCITY,false,n_steps,left_v,right_v)
	end
	if counter_not_exist_or_is_end(avoiding_counter) then 
		log("Do phototaxis")
		log("left_v: " .. tostring(left_v))
		log("right_v: " .. tostring(right_v))
		left_v,right_v = phototaxis_behaviour(robot,left_v,right_v)
		log("left_v: " .. tostring(left_v))
		log("right_v: " .. tostring(right_v))
	end
	left_v,right_v = obstacle_avoidance_behaviour(robot,left_v,right_v,avoiding_counter)
	log("avoiding_counter:get_count() = " .. avoiding_counter:get_count())
	log("avoiding_counter:is_end() = " .. tostring(avoiding_counter:is_end()))
	log("avoiding_counter:is_init() = " .. tostring(avoiding_counter:is_init()))
	log("avoiding_counter:tick() = " .. avoiding_counter:get_count())
	log("left_v: " .. tostring(left_v))
	log("right_v: " .. tostring(right_v))
	robot.wheels.set_velocity(left_v,right_v)
	-- if WANDER and OBSTACLE_AVOIDANCE and PHOTOTAXIS then 
	-- 	left_v,right_v = wander_behaviour(robot,MAX_VELOCITY)
	-- 	left_v,right_v = phototaxis_behaviour(robot, left_v,right_v)
	-- 	left_v,right_v = obstacle_avoidance_behaviour(robot, left_v,right_v)
	-- elseif OBSTACLE_AVOIDANCE then
	-- 	left_v,right_v = obstacle_avoidance_behaviour()
	-- elseif PHOTOTAXIS then
	-- 	left_v,right_v = phototaxis_behaviour()
	-- end
	
	
	-- if OBSTACLE_AVOIDANCE and PHOTOTAXIS then
end

--[[ This function is executed every time you press the 'reset'
button in the GUI. It is supposed to restore the state
of the controller to whatever it was right after init() was
called. The state of sensors and actuators is reset
automatically by ARGoS. ]]
function reset()
	avoiding_counter:reset()
	n_steps = 0
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
end

--[[ This function is executed only once, when the robot is removed
	 from the simulation ]]
function destroy()
	-- put your code here
end

function obstacle_avoidance_behaviour(robot,default_left_v,default_right_v,counter)
	local obs_idx, obs_max = detect_max_sensor_value(robot.proximity)
	if obs_max >= 1 then
		print("TOCCATOOOOOOOO")
	end
	if obs_idx and contains(ALL_FRONTAL_SENSORS,obs_idx) 
		and obs_max >= MINIMUM_DISTANCE_OBSTACLES then
		-- object is in front
		log("See an object")
		counter:reset(counter:get_initial(),robot.random.uniform(2,QUANTUM_STEPS))
		counter:tick()
		log("OA - counter:get_count() = " .. counter:get_count())
		if random_boolean() then 
			return turn_right(MEDIUM_VELOCITY)
		else
			return turn_right(MEDIUM_VELOCITY)
		end
	elseif not counter:is_init() then
		counter:tick()
		if counter:is_end() then counter:reset() end
		log("Counter: " .. counter:get_count())
		return go_forward(MEDIUM_VELOCITY)
	else
		return default_left_v,default_right_v
	end
end

function phototaxis_behaviour(robot,default_left_v,default_right_v)
	local light_idx, light_max = detect_max_sensor_value(robot.light)
	log("sensor[" .. tostring(light_idx) .. "]" .. light_max)
	if light_idx and (not contains(FRONTAL_LIGHT_SENSORS,light_idx)) then 
		-- light detected but is not positioned in front
		log("See light")
		if contains(LEFT_SENSORS,light_idx) then
			return turn_left(MEDIUM_VELOCITY)
		else
			return turn_right(MEDIUM_VELOCITY)
		end
	elseif not light_idx then
		log("No light detected")
		-- no light detected
		return default_left_v,default_right_v
	else
		return go_forward(MAX_VELOCITY)
	end
end

-- Return two random speed between 0 and limit (included).
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

function n_steps_are_passed(steps,quantum_steps)
	return steps % quantum_steps == 0
end

function counter_not_exist_or_is_end(counter)
	return not counter or counter:is_init()
end

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

function contains(table, element)
	for _,value in ipairs(table)
	do
		if value == element then
			return true
		end
	end
	return false
end

function turn_left(speed)
	return -speed,speed	
end

function turn_right(speed)
	return speed,-speed	
end

-- Return two speed equal to passed speed
function go_forward(speed)
	return speed,speed
end


-- Function to get a random boolean ]]
function random_boolean()
	math.randomseed(os.time())
	return (math.random(1, 2) % 2) == 0
end

