-- Global variables
MAX_VELOCITY = 10
MEDIUM_VELOCITY = 5

n_steps = 0


--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = MEDIUM_VELOCITY
	right_v = MEDIUM_VELOCITY
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
end



--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1

	log("robot.position.x = " .. robot.positioning.position.x)
	log("robot.position.y = " .. robot.positioning.position.y)
	log("robot.position.z = " .. robot.positioning.position.z)


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
	if (idx == 1) or (idx == 24) then
		log("I'm go forward")
		robot.wheels.set_velocity(MEDIUM_VELOCITY,MEDIUM_VELOCITY)
	elseif (idx >= 13) then
		log("I'm turning right")
		robot.wheels.set_velocity(MEDIUM_VELOCITY,-MEDIUM_VELOCITY)
	else
		log("I'm turning left")
		robot.wheels.set_velocity(-MEDIUM_VELOCITY,MEDIUM_VELOCITY)
	end

end



--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = MEDIUM_VELOCITY
	right_v = MEDIUM_VELOCITY
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
