local counter = {}
counter.number = 0
counter.initial = 10
function counter:tick() 
	self.number = self.number - 1
end
function counter:reset(default)
	self.number = default or self.initial
end
function counter:is_end()
	return self.number == 0
end