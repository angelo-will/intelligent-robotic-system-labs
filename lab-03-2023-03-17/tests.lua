-- print("prova")
-- ciao = nil
-- print(ciao == nil)
-- print(-1 == nil)
-- print(X)
-- if X then print("miao") end

local pipo = {}

function pipo.wow()
    return "set"
end

function prova(pipo)
    local pipo = pipo or "ciao"
    print(pipo.wow())
end

-- function ciao(ll,rr)
--     return ll,rr or 11,22
-- end

print(not 0)

miao = {1,2,3,4,5,6,7,8,9}

-- local ciao = {}
-- ciao.number = 2
-- ciao.inital = 2

-- ciao:tick(){
--     print("inside tick")
--     self.number = self.number - 1
-- }

-- function ciao:is_end()
--     print("inside is end")
--     return self.number == 0
-- end

-- function ciao:reset()
--     print("inside reset")
--     self.number = self.inital

-- end

-- function wow(element)
--     element.number = element.number - 1
-- end

-- for _,v in ipairs(miao) do
--     -- print("miao v:" .. v)
--     print("ciao.number: " .. tostring(ciao.number))
--     ciao:tick()
--     if ciao:is_end() then ciao:reset() end
-- end

-- local avoiding_counter = {}
-- local miao = {}
-- avoiding_counter.number = 0
-- avoiding_counter.initial = 10
-- function avoiding_counter:tick() 
-- 	self.number = self.number - 1
-- end
-- function avoiding_counter:reset(default)
-- 	self.number = default or self.initial
-- end
-- function avoiding_counter:is_end()
-- 	return self.number == 0
-- end

-- avoiding_counter:reset()
-- if avoiding_counter.tick then avoiding_counter:tick() end
-- print(avoiding_counter.number)

function ciao()
    return 11,12
end
-- print(ciao())
ll,rr = (ciao()) or (78,89)
print(ll .. "  " .. rr)