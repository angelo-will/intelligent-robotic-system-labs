local counter = {}
counter.limit = 10
counter.initial = 0
counter.count = 0
function counter:tick() 
	self.count = self.count + 1
end
function counter:reset(start,finish)
	self.count = start or self.initial
	self.limit = finish or self.limit
end
function counter:is_end()
	return self.count >= self.limit
end
function counter:get_count()
	return self.count
end
function counter:get_initial()
	return self.initial
end
function counter:is_init()
	return self.count == self.initial
end
return counter