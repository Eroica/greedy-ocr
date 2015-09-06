MINIMUM_COMPONENT_WIDTH = 10

local entities = {}

entities.Prototype = class("Prototype", Entity)
function entities.Prototype:__init(literal, image)
    self:add(isPrototype())
    self:add(String(literal))
    self:add(Image(image))

    engine:addEntity(self)
end


entities.Line = class("Line", Entity)
function entities.Line:__init(image, segments)
    self:add(Image(image))
    self:add(isLine())

    self._segments = {}

    for _, segment in ipairs(segments) do
        local width = segment[2] - segment[1] + 1
        local seg = entities.Segment(segment[1], 0, width, image:getHeight(), self)
        table.insert(self._segments, seg)
    end

    engine:addEntity(self)
end


entities.Segment = class("Segment", Entity)
function entities.Segment:__init(l, t, width, height, parent)
    self:setParent(parent)
    self:add(isSegment())
    self:add(Position(l, t))
    self:add(Size(width, height))

    local image_data = love.image.newImageData(width, height)
    image_data:paste(self:getParent():get("Image").image:getData(), 0, 0, l, t, width, height)
    local image = love.graphics.newImage(image_data)
    self:add(Image(image))

    self._components = {}

    local component = entities.Component(0, width - 1, self)
    table.insert(self._components, component)

    engine:addEntity(self)
end

function entities.Segment:split_at (start, _end)
    local s = math.max(0, start)
    local e = math.min(self:get("Size").width, _end)

    assert(e - s > 0)

    local affected_components = {}
    for i=1, #self._components do
        local comp = self._components[i]
        local comp_range = comp:get("Range")

        if comp:has("isPrototype") then
            goto continue
        end

        if ((comp_range.s >= s and comp_range.s <= e) or (comp_range.e >= s and comp_range.e <= e))
        or ((comp_range.s <= s and s <= comp_range.e) or comp_range.s <= e and e <= comp_range.e) then
            table.insert(affected_components, i)
        end

        ::continue::
    end

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
    self:setParent(parent)
    self:add(Range(start, e))
    self:add(String())
    self:add(isComponent())


    local parent_size = self:getParent():get("Size")

    local image_data = love.image.newImageData(e - start + 1, parent_size.height)
    image_data:paste(self:getParent():get("Image").image:getData(), 0, 0, start, 0, e - start + 1, parent_size.height)
    local image = love.graphics.newImage(image_data)
    self:add(Image(image))

    engine:addEntity(self)
end

function entities.Component:overlay(sub_image)
    local image = self:get("Image").image_bw

    assert(image:getWidth() >= sub_image:getWidth())
    assert(image:getHeight() >= sub_image:getHeight())

    local ratios = {}
    local max_y = image:getHeight() - sub_image:getHeight() + 1
    local max_x = image:getWidth() - sub_image:getWidth() + 1

    local wie_oft_hoch = math.floor(image:getHeight() / sub_image:getHeight())
    local wie_oft_breit = math.floor(image:getWidth() / sub_image:getWidth())

    local image_data = image:getData()
    local sub_image_data = sub_image:getData()
    local sub_width, sub_height = sub_image:getWidth(), sub_image:getHeight()
    print(sub_width, sub_height)

    for j=0, max_y - 1 do
        for i=0, max_x - 1 do
            local sum_and, sum_or = 0, 0

            for k=0, sub_width - 1 do
                for l=0, sub_height - 1 do
                    -- print("i+k: " .. tostring(i+k))
                    -- print("k: " .. tostring(k))
                    -- print("j+l: " .. tostring(j+l))
                    -- print("l: " .. tostring(l))
                    -- print("#####")

                    local image_pixel = image_data:getPixel(i+k, j+l)
                    local sub_image_pixel = sub_image_data:getPixel(k, l)

                    sum_and = sum_and + bit.band(image_pixel, sub_image_pixel)
                    sum_or = sum_or + bit.bor(image_pixel, sub_image_pixel)
                end
            end
            table.insert(ratios, sum_and/sum_or)
        end
    end

    return ratios
end

return entities