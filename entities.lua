--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    entities.lua

]]

MINIMUM_COMPONENT_WIDTH = 10
SPLIT_THRESHOLD = 0.69

local Entities = {}

Entities.Prototype = class("Prototype")
function Entities.Prototype:init (literal, image)
    self.isPrototype = true
    self.string = literal
    self.image = image


    getmetatable(self).__tostring = function (t)
        return t.string
    end



    WORLD:addEntity(self)
end


Entities.Page = class("Page")
function Entities.Page:init (image, segments)
    self.isPage = true
    self.image = image
    self.position = {l = 0, t = 0}

    self.segments = {}

    for _, segment in ipairs(segments) do
        local start = segment[1]
        local e = segment[2]

        local width = e[1] - start[1]
        local height = e[2] - start[2]

        local image_data = love.image.newImageData(width, height)
        image_data:paste(image:getData(), 0, 0, l, t, width, height)
        local image = love.graphics.newImage(image_data)

        local seg = Entities.Segment:new(start[1], start[2], width, height, image)
        table.insert(self.segments, seg)
    end

    WORLD:addEntity(self)
end


Entities.Segment = class("Segment")
function Entities.Segment:init (l, t, width, height, image)
    assert(width == image:getWidth())
    assert(height == image:getHeight())

    self.isSegment = true
    self.isNotRecognized = true
    self.position = {l = l, t = t}
    self.size = {width = width, height = height}
    self.components = {}
    self.image = image


    -- local image_data = love.image.newImageData(width, height)
    -- image_data:paste(image:getData(), 0, 0, 0, 0, width, height)
    -- self.image = love.graphics.newImage(image_data)

    self.components[1] = Entities.Component(0, width - 1, image)

    getmetatable(self).__tostring = function (t)
        local str = {}

        for _, component in pairs(t.components) do
            table.insert(str, component.string)
        end

        return table.concat(str)
    end

    WORLD:addEntity(self)
end

function Entities.Segment:split_component (c, start, e)

    local affected_component = self.components[c]
    local affected_width = affected_component.range[2] - affected_component.range[1]
    local e = math.min(e, affected_width)

    local new_components = {}

    if start >= MINIMUM_COMPONENT_WIDTH then
        local left_image = affected_component:crop_image(0, start)
        table.insert(new_components, Entities.Component(affected_component.range[1], affected_component.range[1] + start, left_image))
    end

    local middle_image = affected_component:crop_image(start, e)
    table.insert(new_components, Entities.Component(affected_component.range[1] + start, affected_component.range[1] + e, middle_image))

    if math.abs(affected_component.range[2] - affected_component.range[1] - e) >= MINIMUM_COMPONENT_WIDTH then
        local right_image = affected_component:crop_image(e)

        print "created right image of width"
        print(right_image:getWidth())
        table.insert(new_components, Entities.Component(affected_component.range[1] + e, affected_component.range[2], right_image))
    end

    table.remove(self.components, c)

    for i=1, #new_components do
        table.insert(self.components, c + i - 1, new_components[i])
    end
end


Entities.Component = class("Component")
function Entities.Component:init (start, e, image)
    assert(e - start + 1 == image:getWidth())
    self.isComponent = true
    self.range = {start, e}
    self.string = literal or ".*"
    self.image = image


    getmetatable(self).__tostring = function (t)
        return t.string
    end


    WORLD:addEntity(self)
end


function Entities.Component:crop_image (start, e)
    local e = e or self.image:getWidth() - 1
    local component_image = self.image
    local height = component_image:getHeight()

    local image_data = love.image.newImageData(e - start + 1, height)
    image_data:paste(component_image:getData(), 0, 0, start, e, e - start + 1, height)
    local image = love.graphics.newImage(image_data)

    return image
end




-- function entities.Segment:split_at (start, _end, str)
--     local s = math.max(0, start)
--     local e = math.min(self:get("Size").width, _end)

--     assert(e - s > 0)

--     local affected_components = {}
--     for i=1, #self._components do
--         local comp = self._components[i]
--         local comp_range = comp:get("Range")

--         -- if comp:has("isPrototype") then
--         --     goto continue
--         -- end
--         if comp:get("String").string ~= ".*" then
--             goto continue
--         end

--         if ((comp_range.s >= s and comp_range.s <= e) or
--             (comp_range.e >= s and comp_range.e <= e))
--         or ((comp_range.s <= s and s <= comp_range.e) or
--             comp_range.s <= e and e <= comp_range.e) then
--             table.insert(affected_components, i)
--         end

--         ::continue::
--     end

--     local left_component = self._components[affected_components[1]]
--     local left_component_range = left_component:get("Range")
--     local right_component = self._components[affected_components[#affected_components]]
--     local right_component_range = right_component:get("Range")

--     for i=#affected_components, 1, -1 do
--         table.remove(self._components, affected_components[i])
--     end

--     local new_components = {}
--     if math.abs(left_component_range.s - s) >= MINIMUM_COMPONENT_WIDTH then
--         table.insert(new_components, entities.Component(left_component_range.s, s, self))
--     end

--     table.insert(new_components, entities.Component(s, e, self, str))

--     if math.abs(right_component_range.e - e) >= MINIMUM_COMPONENT_WIDTH then
--         table.insert(new_components, entities.Component(e, right_component_range.e, self))
--     end

--     for i=1, #new_components do
--         table.insert(self._components, affected_components[1] + i - 1, new_components[i])
--     end
-- end


-- entities.Component = class("Component", Entity)
-- function entities.Component:__init(start, e, parent, literal)
--     self:setParent(parent)
--     self:add(Range(start, e))
--     self:add(String(literal))
--     self:add(isComponent())

--     local parent_size = parent:get("Size")

--     local image_data = love.image.newImageData(e - start + 1, parent_size.height)
--     image_data:paste(parent:get("Image").image:getData(), 0, 0, start, 0, e - start + 1, parent_size.height)
--     local image = love.graphics.newImage(image_data)
--     self:add(Image(image))

--     self._string_hypothesis = {}

--     engine:addEntity(self)
-- end

-- function entities.Component:overlay(prototype)
--     local sub_image = prototype:get("Image").image_bw
--     local image = self:get("Image").image_bw

--     assert(image:getWidth() >= sub_image:getWidth())
--     assert(image:getHeight() >= sub_image:getHeight())

--     local ratios = {}
--     local max_y = image:getHeight() - sub_image:getHeight() + 1
--     local max_x = image:getWidth() - sub_image:getWidth() + 1

--     local image_data = image:getData()
--     local sub_image_data = sub_image:getData()
--     local sub_width, sub_height = sub_image:getWidth(), sub_image:getHeight()

--     for j=0, max_y - 1 do
--         for i=0, max_x - 1 do
--             local sum_and, sum_or = 0, 0

--             for k=0, sub_width - 1 do
--                 for l=0, sub_height - 1 do
--                     -- print("i+k: " .. tostring(i+k))
--                     -- print("k: " .. tostring(k))
--                     -- print("j+l: " .. tostring(j+l))
--                     -- print("l: " .. tostring(l))
--                     -- print("#####")

--                     local image_pixel = image_data:getPixel(i+k, j+l)
--                     local sub_image_pixel = sub_image_data:getPixel(k, l)

--                     sum_and = sum_and + bit.band(image_pixel, sub_image_pixel)
--                     sum_or = sum_or + bit.bor(image_pixel, sub_image_pixel)
--                 end
--             end
--             table.insert(ratios, sum_and/sum_or)
--         end
--     end


--     local max_ratio_index, max_ratio = max_pair(ratios)
--     -- IMPORTANT:
--     -- From `max_ratio_index', 1 needs to be subtracted because the
--     -- `ratios' tables starts indexing at 1 while the ImageData table
--     -- (used in `:getData()') starts indexing at 0!
--     max_ratio_index = max_ratio_index - 1

--     local split_x, split_y = max_ratio_index % max_x, math.floor(max_ratio_index / max_x)

--     if config.DEBUG then
--         print(max_ratio_index, max_ratio, split_x, split_x + sub_image:getWidth())
--     end

--     if max_ratio >= SPLIT_THRESHOLD then
--         self:getParent():split_at(split_x, split_x + sub_image:getWidth(), prototype:get("String").string)
--     end

--     -- return ratios
-- end

return Entities