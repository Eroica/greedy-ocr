MERCURIUS_FILENAME = "../share/mercurius.txt"
MERCURIUS_FILE = io.open(MERCURIUS_FILENAME)

st = {}
lt = {}

function allwords ()
    local line = MERCURIUS_FILE:read()
    local pos = 1
    return function ()
        while line do
            local s, e = string.find(line, "%S+", pos)
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

function allletters ()
    local line = MERCURIUS_FILE:read()
    local pos = 1
    return function ()
        while line do
            local s, e = string.find(line, "[%g%s]", pos)
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

function insert (bag, element)
    bag[0] = (bag[0] or 0) + 1
    bag[element] = (bag[element] or 0) + 1
end

function remove (bag, element)
    local count = bag[element]
    bag[element] = (count and count > 1) and count - 1 or nil
end

-- local w1, w2 = "", ""
-- for w in allletters() do
--     w1 = w2; w2 = w;

--     if lt[w1] == nil then
--         lt[w1] = {}
--     else
--         insert(lt[w1], w2)
--     --     table.insert(st[w1], w2)
--     end
-- end


local w1, w2 = "", ""
for w in allwords() do
    w1 = w2; w2 = w;

    if st[w1] == nil then
        st[w1] = {}
    else
        insert(st[w1], w2)
    --     table.insert(st[w1], w2)
    end
end