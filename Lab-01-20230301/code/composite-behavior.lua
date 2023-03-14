-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
MEDIUM_VELOCITY = 5
n_steps = 0
not_avoiding = true
NO_OBSTACLES = -1

QUARTER_STEPS_ROTATION = 21
HALF_ROTATION = 42

NO_QUARTER = 0
QUARTER_NE = 1
QUARTER_SE = 2
QUARTER_SW = 3
QUARTER_NW = 4

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = MAX_VELOCITY
	right_v = MAX_VELOCITY
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	not_avoiding = true
	avoiding_steps = 0
	
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1

	light_idx = -1
	light_max = -1
	light_quarter = NO_QUARTER
	for i=1,#robot.light do
		-- log("robot.light[".. i .. "] = " .. robot.light[i].value)
		if robot.light[i].value > light_max then
			light_idx = i
			light_max = robot.light[i].value
		end
	end
	if (light_idx > -1) then
		light_quarter = quarter_by_index(light_idx)
	end


	prox_idx = NO_OBSTACLES -- index of the highest value
	prox_value = NO_OBSTACLES -- highest value found so far
	prox_quarter = NO_QUARTER
	for i=1,#robot.proximity do
		-- log("robot.proximity[" .. i .. "]=" .. robot.proximity[i].value)
		if prox_value < robot.proximity[i].value then
			prox_idx = i
			prox_value = robot.proximity[i].value
		end
	end
	
	if (prox_value >= 0.2 ) then
		prox_quarter = quarter_by_index(prox_idx)
	else
		prox_idx = NO_OBSTACLES
	end
	
	if (prox_idx == NO_OBSTACLES) and not_avoiding then
		log("Obstacles not present and i'm not avoiding")
		-- Gira verso la luce
		if ((light_idx >= 1) and (light_idx <= 2)) or ((light_idx >= 23) and (light_idx <= 24)) then
			log("I'm go forward")
			left_v = MAX_VELOCITY
			right_v = MAX_VELOCITY
		elseif (light_idx >= 13) then
			log("I'm turning right")
			left_v = MAX_VELOCITY
			right_v = -MAX_VELOCITY
		else
			log("I'm turning left")
			left_v = -MAX_VELOCITY
			right_v = MAX_VELOCITY
		end
	elseif (prox_idx == NO_OBSTACLES) then
		-- mantengo la velocità di prima dato che sto evitando
		log("I'm still avoiding")
		if(avoiding_steps >= 1) then
			avoiding_steps = avoiding_steps - 1
		end
		-- elseif (not_avoiding) then
	else
		log("Start avoiding")
		-- in questo caso non stavo evitando ma ora sono presenti ostacoli
		if (prox_quarter == QUARTER_NW or prox_quarter == QUARTER_NE) then
			-- ostacolo davanti
			if (light_quarter == QUARTER_NW) or (light_quarter == QUARTER_NE) then
				-- luce davanti
				avoiding_steps = QUARTER_STEPS_ROTATION
			else
				-- luce dietro
				avoiding_steps = HALF_ROTATION
			end
			-- ruoto a dx o sx in maniera casuale
			if random_boolean then 
				left_v = MAX_VELOCITY
				right_v = -MAX_VELOCITY
			else 
				left_v = MAX_VELOCITY
				right_v = -MAX_VELOCITY
			end
			not_avoiding = false
		else 
			-- ostacolo dietro
			if(avoiding_steps >= 1) then
				avoiding_steps = avoiding_steps - 1
			end
			-- not_avoiding = true
			left_v = MAX_VELOCITY
			right_v = MAX_VELOCITY
		end
	end

	if avoiding_steps <= 0 then
		not_avoiding = true
	end

	log("lightSensor[" .. light_idx .. "] = " .. light_max)
	log("light_quarter = ".. light_quarter)
	log("proximitySensor[" .. prox_idx .. "] = " .. prox_value)
	log("prox_quarter = ".. prox_quarter)
	log("not_avoiding = " .. tostring(not_avoiding))
	log("avoiding_steps = " .. avoiding_steps)

	robot.wheels.set_velocity(left_v,right_v)
end

--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = MAX_VELOCITY
	right_v = MAX_VELOCITY
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	not_avoiding = true
	avoiding_steps = 0
	
end

function random_boolean()
	math.randomseed(os.time())
	return (math.random(1,2) % 2) == 0
end

function quarter_by_index(idx)
	if (idx >= 1) and (idx <= 6) then
		return QUARTER_NW
	elseif (idx >= 7) and (idx <= 12) then
		return QUARTER_SW
	elseif (idx >= 13) and (idx <= 18) then
		return QUARTER_SE
	elseif (idx >= 19) and (idx <= 24) then
		return QUARTER_NE
	end
end

--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
