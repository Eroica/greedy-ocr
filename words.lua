local function allwords ()
    local auxwords = function ()
        for line in io.lines() do
            for word in string.gmatch(line, "%w+") do
                coroutine.yield(word)
            end
        end
    end
    return coroutine.wrap(auxwords)
end

local counter = {}
for w in allwords do
    counter[w] = (counter[w] or 0) + 1
end

local words = {}
for w in pairs(counter) do
    words[#words + 1] = w
end