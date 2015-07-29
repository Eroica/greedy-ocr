local Lexicon = {}

function Lexicon.new (filename)
    local self = {}
    local lexicon_file = io.open(filename, "r")
    local _lexicon = {}

    for line in lexicon_file:lines() do
        self[line] = true
        _lexicon[#_lexicon + 1] = line
    end

    function self.contains (str)
        return self[str] ~= nil
    end

    function self.lookup (str)
        local matches = {}

        for i=1, #_lexicon do
            local s, e = _lexicon[i]:find(str)
            if s then
                matches[#matches + 1] = _lexicon[i]
            end
        end

        return matches
    end

    return self
end

return Lexicon