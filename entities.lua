local entities = {}

entities.Test = class("Test", Entity)
function entities.Test:__init()
    self:add(Position(3, 3))

    self._segments = {}

    engine:addEntity(self)
end

function entities.Test:split_at()
    print "hello"
end


entities.Line = class("Line", Entity)
function entities.Line:__init(image, segments)
    self:add(Image(image))
    self:add(isLine)

    self._segments = {}

    for _, segment in ipairs(segments) do
        local width = segment[2] - segment[1] + 1
        local seg = entities.Segment(segment[1], segment[2], width, image:getHeight(), self)
        table.insert(self._segments, seg)
    end

    engine:addEntity(self)
end




entities.Segment = class("Segment", Entity)
function entities.Segment:__init(l, t, width, height, parent)
    self:add(isSegment)
    self:add(Position(l, t))
    self:add(Size(width, height))

    self._components = {}

    local component = entities.Component(0, width - 1, self)
    table.insert(self._components, component)
    self:setParent(parent)

    engine:addEntity(self)
end



function entities.Segment:split_at (start, _end)
    local s = math.max(0, start)
    local e = math.min(self:get("Size").width, _end)

    print(s,e)

    assert(e - s > 0)

    local affected_components = {}
    for i=1, #self._components do
        local comp = self._components[i]
        local comp_range = comp:get("Range")

        -- if comp:get("String").string ~= ".*" then
        --     goto continue
        -- end

        if ((comp_range.s >= s and comp_range.s <= e) or (comp_range.e >= s and comp_range.e <= e))
        or ((comp_range.s <= s and s <= comp_range.e) or comp_range.s <= e and e <= comp_range.e) then
            table.insert(affected_components, i)
        end

        -- ::continue::
    end

    --print(inspect(affected_components))

    local left_component = self._components[affected_components[1]]
    local right_component = self._components[affected_components[#affected_components]]

    for i=#affected_components, 1, -1 do
        table.remove(self._components, affected_components[i])
    end

    local new_components = {}
    if math.abs(left_component:get("Range").s - s) >= MINIMUM_COMPONENT_WIDTH then
        table.insert(new_components, entities.Component(left_component:get("Range").s, s, self))
    end

    table.insert(new_components, entities.Component(s, e, self))

    if math.abs(right_component:get("Range").e - e) >= MINIMUM_COMPONENT_WIDTH then
        table.insert(new_components, entities.Component(e, right_component:get("Range").e, self))
    end

    for i=1, #new_components do
        table.insert(self._components, affected_components[1] + i - 1, new_components[i])
    end
end






entities.Component = class("Component", Entity)
function entities.Component:__init(start, e, parent)
    self:add(Range(start, e))
    self:add(String())
    self:add(isComponent())

    self:setParent(parent)

    engine:addEntity(self)
end

return entities