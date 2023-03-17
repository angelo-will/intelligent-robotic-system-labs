-- Global variables
MOVE_STEPS = 30
MAX_VELOCITY = 10

n_steps = 0

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		left_v = robot.random.uniform(0,MAX_VELOCITY)
		right_v = robot.random.uniform(0,MAX_VELOCITY)
	end
	robot.wheels.set_velocity(left_v,right_v)
	log("robot.position.x = " .. robot.positioning.position.x)
	log("robot.position.y = " .. robot.positioning.position.y)
	log("robot.position.z = " .. robot.positioning.position.z)
	
	-- Search for the reading with the highest value
	value = -1 -- highest value found so far
	idx = -1   -- index of the highest value
	for i=1,#robot.proximity do
		log("robot.proximity[" .. i .. "]=" .. robot.proximity[i].value)
		if value < robot.proximity[i].value then
			idx = i
			value = robot.proximity[i].value
		end
	end

	--[[ If an object is distant less than 8cm new speed for robot is computed.
		 New speed is setted according to allow the robot to go away from object.]]
	if (value >= 0.2) then
		log("I'm avoiding")
		if ((idx >= 1) and (idx < 7)) or ((idx > 18) and (idx <= 24)) then
			left_v = -robot.random.uniform(0,MAX_VELOCITY)
			right_v = -robot.random.uniform(0,MAX_VELOCITY)
		else 
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = robot.random.uniform(0,MAX_VELOCITY)
		end
		n_steps = 0
	end


end



--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
