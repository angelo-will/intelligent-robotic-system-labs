local n_steps = 0

-- Function to set initial parameters of simulation
function initialize_simulation()
	n_steps = 0
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