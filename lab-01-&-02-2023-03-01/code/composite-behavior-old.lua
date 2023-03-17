-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
MEDIUM_VELOCITY = 5
resetable_counter_steps = 0
n_steps = 0
free_from_obstacles = true
AVOIDING_STEPS = 15
LIMIT_ROTATION_STEPS = 15
rotation_steps = LIMIT_ROTATION_STEPS
TURN_RIGHT = 1
TURN_LEFT = 2
NO_OBSTACLES = -1
-- turn = 0

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	-- left_v = robot.random.uniform(0,MAX_VELOCITY)
	-- right_v = robot.random.uniform(0,MAX_VELOCITY)
	left_v = MAX_VELOCITY
	right_v = MAX_VELOCITY
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	-- turn = 0
	rotation_steps = LIMIT_ROTATION_STEPS
	resetable_counter_steps = 0
	free_from_obstacles = true
	-- counter_next_move_steps = 0
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1
	-- counter_next_move_steps = counter_next_move_steps + 1
	-- if counter_next_move_steps == MOVE_STEPS then
	-- 	left_v = robot.random.uniform(0,MAX_VELOCITY)
	-- 	right_v = robot.random.uniform(0,MAX_VELOCITY)
	-- 	counter_next_move_steps = 0
	-- end
	log("robot.position.x = " .. robot.positioning.position.x)
	log("robot.position.y = " .. robot.positioning.position.y)
	log("robot.position.z = " .. robot.positioning.position.z)


	if free_from_obstacles then
		--[[ Check which sensor receive more light.
		Robot will turn to be in front of light ]]
		idx = -1
		max = -1
		for i=1,#robot.light do
			-- log("robot.light[".. i .. "] = " .. robot.light[i].value)
			if robot.light[i].value > max then
				idx = i
				max = robot.light[i].value
			end
		end
		log("Index brightest: " .. idx)

		-- To reduce rotation time, the robot turns left or right 
		-- according to nearest light sensor
		if ((idx >= 1) and (idx <= 2)) or ((idx >= 23) and (idx <= 24)) then
			log("I'm go forward")
			left_v = MAX_VELOCITY
			right_v = MAX_VELOCITY
		elseif (idx >= 13) then
			log("I'm turning right")
			left_v = MAX_VELOCITY
			right_v = -MAX_VELOCITY
		else
			log("I'm turning left")
			left_v = -MAX_VELOCITY
			right_v = MAX_VELOCITY
		end
	else
		if resetable_counter_steps == AVOIDING_STEPS then
			resetable_counter_steps = 0
			free_from_obstacles = true
		else
			resetable_counter_steps = resetable_counter_steps + 1
		end
	end
	
	-- Search for the reading with the highest value
	value = -1 -- highest value found so far
	idx = -1   -- index of the highest value
	for i=1,#robot.proximity do
		-- log("robot.proximity[" .. i .. "]=" .. robot.proximity[i].value)
		if value < robot.proximity[i].value then
			idx = i
			value = robot.proximity[i].value
		end
	end

	-- --[[ If an object is distant less than 9cm new speed for robot is computed.
	-- 	 New speed is setted according to allow the robot to go away from object.]]
	-- if (value >= 0.1) then
	-- 	free_from_obstacles = false
	-- 	resetable_counter_steps = 1
	-- 	log("I'm avoiding")
	-- 	if ((idx >= 1) and (idx <= 4)) then
	-- 		left_v = MEDIUM_VELOCITY
	-- 		right_v = -MEDIUM_VELOCITY
	-- 	elseif ((idx >= 21) and (idx <= 24)) then
	-- 		left_v = -MEDIUM_VELOCITY
	-- 		right_v = MEDIUM_VELOCITY
	-- 	else
	-- 		left_v = MEDIUM_VELOCITY
	-- 		right_v = MEDIUM_VELOCITY
	-- 	end
	-- 	-- counter_next_move_steps = 0
	-- end
	
	--[[ If an object is distant less than 9cm new speed for robot is computed.
		 New speed is setted according to allow the robot to go away from object.]]
	if (value >= 0.1) and (rotation_steps >= LIMIT_ROTATION_STEPS) then
		free_from_obstacles = false
		resetable_counter_steps = 1
		log("I'm avoiding, proximitySensor[" .. idx .. "] = " .. value)
		-- if rotation_steps == LIMIT_ROTATION_STEPS then
			if ((idx >= 1) and (idx <= 7)) then
				left_v = robot.random.uniform(0,MEDIUM_VELOCITY)
				right_v = -robot.random.uniform(0,MEDIUM_VELOCITY)
				rotation_steps = 1
			elseif ((idx >= 18) and (idx <= 24)) then
				left_v = -robot.random.uniform(0,MEDIUM_VELOCITY)
				right_v = robot.random.uniform(0,MEDIUM_VELOCITY)
				rotation_steps = 1
			else
				left_v = MAX_VELOCITY	
				right_v = MAX_VELOCITY
			end
	else
			rotation_steps = rotation_steps + 1
	end
	

		-- Prove per fargli decidere rancomicamente dove andare
		-- se si trova un ostacolo con i sensori davanti
	-- --[[ If an object is distant less than 9cm new speed for robot is computed.
	-- 	 New speed is setted according to allow the robot to go away from object.]]
	-- 	 if (value >= 0.1) then
	-- 		free_from_obstacles = false
	-- 		resetable_counter_steps = 1
	-- 		log("I'm avoiding")
	-- 		if ((idx >= 1) and (idx <= 2)) or ((idx >= 23) and (idx <= 24)) then
	-- 			if random_boolean() then
	-- 				turn = TURN_LEFT
	-- 			else
	-- 				turn = TURN_RIGHT
	-- 			end
			


	-- 			left_v = MEDIUM_VELOCITY
	-- 			right_v = -MEDIUM_VELOCITY
	-- 		elseif ((idx >= 21) and (idx <= 24)) then
	-- 			left_v = -MEDIUM_VELOCITY
	-- 			right_v = MEDIUM_VELOCITY
	-- 		else
	-- 			left_v = MEDIUM_VELOCITY
	-- 			right_v = MEDIUM_VELOCITY
	-- 		end
	-- 		-- counter_next_move_steps = 0
	-- 	end
		
	robot.wheels.set_velocity(left_v,right_v)
end

-- function step()
-- 	robot.wheels.set_velocity(5,-5)
-- end

--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	-- left_v = robot.random.uniform(0,MAX_VELOCITY)
	-- right_v = robot.random.uniform(0,MAX_VELOCITY)
	left_v = MAX_VELOCITY
	right_v = MAX_VELOCITY
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	-- turn = 0
	rotation_steps = LIMIT_ROTATION_STEPS
	resetable_counter_steps = 0
	free_from_obstacles = true
	-- counter_next_move_steps = 0
end

function random_boolean()
	math.randomseed(os.time())
	return (math.random(1,2) % 2) == 0
end

--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
