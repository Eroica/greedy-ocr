--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    entities.lua

]]

MINIMUM_COMPONENT_WIDTH = 10
SPLIT_THRESHOLD = 0.75

local Entities = {}

Entities.Prototype = class("Prototype")
function Entities.Prototype:init (literal, image)
    self.isPrototype = true
    self.string = literal
    self.image = image
    self.bw_image = threshold_image(image)

    getmetatable(self).__tostring = function (t)
        return t.string
    end

    WORLD:addEntity(self)
end


Entities.Page = class("Page")
function Entities.Page:init (image, bounding_boxes)
    self.isPage = true
    self.image = image
    self.position = {l = 0, t = 0}

    self.segments = {}

    for _, box in ipairs(bounding_boxes) do
        local l = box[1]
        local t = box[2]
        local width = box[3]
        local height = box[4]

        local segment = Entities.Segment:new(l, t, width, height, self)
        table.insert(self.segments, segment)
    end

    WORLD:addEntity(self)
end


Entities.Segment = class("Segment")
function Entities.Segment:init (l, t, width, height, parent)
    local function all_white (t)
        for i=1, #t do
            if t[i] ~= 255 then return false end
        end

        return true
    end

    self.parent = parent
    self.isSegment = true
    self.isNotRecognized = true
    self.position = {l = l, t = t}
    self.size = {width = width, height = height}

    local image_data = love.image.newImageData(width, height)
    image_data:paste(parent.image:getData(), 0, 0, l, t, width, height)
    self.image = love.graphics.newImage(image_data)

    self.components = {}


    local image_bw = threshold_image(self.image)

    local lines = {}
    local component_edges = {}
    local search_black = true
    local num_white_rows = 0

    for column_idx=0, image_bw:getWidth() - 1 do
        local colors = {}

        for row_idx=0, image_bw:getHeight() - 1 do
            local r, g, b = image_bw:getData():getPixel(column_idx, row_idx)
            table.insert(colors, rgb2grey(r, g, b))
        end

        if not all_white(colors) then
            if search_black then
                table.insert(component_edges, math.max(column_idx - 1, 0))
                search_black = false
            end
        else
            if search_black then
                goto continue
            else
                num_white_rows = num_white_rows + 1
                if num_white_rows == 3 then
                    search_black = true
                    table.insert(component_edges, column_idx - 1)
                    num_white_rows = 0
                end
            end
        end
        ::continue::
    end


    for i=1, #component_edges, 2 do
        local start = component_edges[i] - 3
        if start < 0 then start = 0 end
        local _end = component_edges[i+1] or image_bw:getWidth() - 1

        table.insert(self.components, Entities.Component(start, _end, self))
    end


    getmetatable(self).__tostring = function (t)
        local str = {}

        for _, component in pairs(t.components) do
            table.insert(str, component.string)
        end

        return table.concat(str)
    end

    WORLD:addEntity(self)
end


Entities.Component = class("Component")
function Entities.Component:init (start, e, parent)
    self.parent = parent
    self.isComponent = true
    self.range = {start, e}
    self.string = literal or ".*"
    self.visitedBy = {}

    local width = e - start + 1
    local height = parent.size.height
    local image_data = love.image.newImageData(width, height)
    image_data:paste(parent.image:getData(), 0, 0, start, 0, width, height)
    self.image = love.graphics.newImage(image_data)

    getmetatable(self).__tostring = function (t)
        return t.string
    end

    WORLD:addEntity(self)
end


function Entities.Component:split (start, e, str)
    local width = self.range[2] - self.range[1] + 1
    local start = math.max(0, start)
    local e = math.min(e, width)

    local new_components = {}

    if start >= MINIMUM_COMPONENT_WIDTH then
        table.insert(new_components, Entities.Component(self.range[1], self.range[1] + start, self.parent))
    end

    local middle_component = Entities.Component(self.range[1] + start, self.range[1] + e, self.parent)
    middle_component.string = str
    table.insert(new_components, middle_component)

    if math.abs(self.range[2] - self.range[1] - e) >= MINIMUM_COMPONENT_WIDTH then
        table.insert(new_components, Entities.Component(self.range[1] + e, self.range[2], self.parent))
    end

    local index = invert_table(self.parent.components)[self]
    WORLD:removeEntity(self)
    table.remove(self.parent.components, index)

    for i=1, #new_components do
        table.insert(self.parent.components, index + i - 1, new_components[i])
    end
end



function Entities.Component:overlay (prototype)
    assert(class.isInstance(prototype, Prototype))

    local sub_image = prototype.bw_image
    local image = threshold_image(self.image)

    assert(image:getWidth() >= sub_image:getWidth())
    assert(image:getHeight() >= sub_image:getHeight())

    local ratios = {}
    local max_y = image:getHeight() - sub_image:getHeight() + 1
    local max_x = image:getWidth() - sub_image:getWidth() + 1

    local image_data = image:getData()
    local sub_image_data = sub_image:getData()
    local sub_width, sub_height = sub_image:getWidth(), sub_image:getHeight()

    for j=0, max_y - 1 do
        for i=0, max_x - 1 do
            local sum_and, sum_or = 0, 0

            for k=0, sub_width - 1 do
                for l=0, sub_height - 1 do
                    local image_pixel = image_data:getPixel(i+k, j+l)
                    local sub_image_pixel = sub_image_data:getPixel(k, l)

                    sum_and = sum_and + bit.band(image_pixel, sub_image_pixel)
                    sum_or = sum_or + bit.bor(image_pixel, sub_image_pixel)
                end
            end
            table.insert(ratios, sum_and/sum_or)
        end
    end


    local max_ratio_index, max_ratio = max_pair(ratios)
    -- IMPORTANT:
    -- From `max_ratio_index', 1 needs to be subtracted because the
    -- `ratios' tables starts indexing at 1 while the ImageData table
    -- (used in `:getData()') starts indexing at 0!
    max_ratio_index = max_ratio_index - 1

    local split_x, split_y = max_ratio_index % max_x, math.floor(max_ratio_index / max_x)

    if config.DEBUG then
        print(max_ratio_index, max_ratio, split_x, split_x + sub_image:getWidth(), prototype.string)
    end

    if max_ratio >= SPLIT_THRESHOLD then
        self:split(split_x, split_x + sub_image:getWidth(), prototype.string)
    end
end

return Entities