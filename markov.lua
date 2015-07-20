MERCURIUS_FILENAME = "share/mercurius.txt"
MERCURIUS_FILE = io.open(MERCURIUS_FILENAME)


function allwords ()
    local line = MERCURIUS_FILE:read()
    local pos = 1
    return function ()
        while line do
            local s, e = string.find(line, "[%w%päöüÄÖÜßæÆ]+", pos)
            if s then
                pos = e + 1
                return string.sub(line, s, e)
            else
                line = MERCURIUS_FILE:read()
                pos = 1
            end
        end
        return nil
    end
end


function prefix (w1, w2)
    return w1 .. ' ' .. w2
end

local statetab = {}

function insert (index, value)
    local list = statetab[index]
    if list == nil then
        statetab[index] = {value}
    else
        list[#list + 1] = value
    end
end

local N  = 2
local MAXGEN = 10000
local NOWORD = "\n"

-- build table
local w1, w2 = NOWORD, NOWORD
for w in allwords() do
  insert(prefix(w1, w2), w)
  w1 = w2; w2 = w;
end
insert(prefix(w1, w2), NOWORD)


-- generate text
w1 = NOWORD; w2 = NOWORD     -- reinitialize
for i=1,MAXGEN do
  local list = statetab[prefix(w1, w2)]
  -- choose a random item from list
  local r = math.random(#list)
  local nextword = list[r]
  if nextword == NOWORD then return end
  io.write(nextword, " ")
  w1 = w2; w2 = nextword
end