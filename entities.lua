--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    entities.lua

]]

local config = require "_config"

local Entities = {}


-- Creates a `Prototype' entity. A Prototype doesn't need many helper
-- methods, so this is basically a list of fields.
--
-- @params: literal: The Prototype string
--          |__@type: string
--          image: The Prototype image
--          |__@type: Image
-- @returns: @type: Prototype
Entities.Prototype = class("Prototype")
function Entities.Prototype:init (literal, image)
    self.isPrototype = true
    self.string = literal
    self.image = trim_image(image)
    self.image_bw = threshold_image(self.image)

    getmetatable(self).__tostring = function (t)
        return t.string
    end

    WORLD:addEntity(self)
end


-- Creates a `Page' entity. A Page represents a document (image) that
-- should be recognized, and is parent to `Segment' entities.
--
-- @params: image: The Page image
--          |__@type: Image
--          bounding_boxes: A table of bounding boxes that contain words
--          |               on that page.
--          |__@type: table
-- @returns: @type: Page
Entities.Page = class("Page")
function Entities.Page:init (image, bounding_boxes)
    self.isPage = true
    self.image = image
    self.image_bw = threshold_image(image)
    self.position = {l = 0, t = 0}

    -- This Page's Segments (words)
    self.segments = {}

    -- Iterate over `bounding_boxes' and create Segments.
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


-- all_white:
-- A helper function that checks whether every value in a table is
-- `255' (white).
local function all_white (t)
    for i=1, #t do
        if t[i] ~= 255 then return false end
    end

    return true
end


-- Creates a `Segment' entity. A Segment represents a word that should
-- be recognized, and consists of individual `Components'.
--
-- @params: l: Left position on the page
--          |__@type: number
--          t: Top position on the page
--          |__@type: number
--          width: Width of the bounding box
--          |__@type: number
--          height: Height of the bounding box
--          |__@type: number
--          parent: The Page entity on which this Segment is
--          |__@type: Page *
-- @returns: @type: Segment
Entities.Segment = class("Segment")
function Entities.Segment:init (l, t, width, height, parent)
    self.parent = parent
    self.isSegment = true
    self.isNotRecognized = true
    self.position = {l = l, t = t}
    self.size = {width = width, height = height}

    local image_data = love.image.newImageData(width, height)
    image_data:paste(parent.image:getData(), 0, 0, l, t, width, height)
    self.image = love.graphics.newImage(image_data)

    self.components = {}
    self.image_bw = threshold_image(self.image)

    -- Automatically split Segment into smaller components when
    -- specified so in `_config.lua'
    if config.automatically_split_segments then
        self:split_at_whitespace()
    -- Do not split Segment, just create a single Component covering the
    -- whole Segment
    else
        table.insert(self.components, Entities.Component(0, width, self))
    end --if

    getmetatable(self).__tostring = function (t)
        local str = {}

        for _, component in pairs(t.components) do
            table.insert(str, component.string)
        end

        return self.string or table.concat(str)
        --return table.concat(str)
    end

    WORLD:addEntity(self)
end

-- This helper method splits a Segment into smaller Components, and
-- should be used in the beginning of Segment initialization.
function Entities.Segment:split_at_whitespace ()
    local lines = {}
    local component_edges = {}
    local search_black = true
    local num_white_rows = 0

    -- Check where columns of white pixels are in this Segment's image.
    local white_columns = {}
    for column_idx=0, self.image_bw:getWidth() - 1 do
        local colors = {}

        for row_idx=0, self.image_bw:getHeight() - 1 do
            local r, g, b = self.image_bw:getData():getPixel(column_idx, row_idx)
            table.insert(colors, rgb2grey(r, g, b))
        end

        if all_white(colors) then
            table.insert(white_columns, column_idx)
        end
    end

    -- Check if the neighbors of this white columns are also white.
    -- It will serve as a starting/ending point for a Component only if
    -- these white columns are "large" enough.
    for i, white_col in pairs(white_columns) do
        local start = white_col - 2
        if start < 0 then start = 0 end

        local _end = white_col + 2
        if _end >= self.image_bw:getWidth() then _end = self.image_bw:getWidth() - 1 end

        for j=start, _end do
            local colors = {}

            for row_idx=0, self.image_bw:getHeight() - 1 do
                local r, g, b = self.image_bw:getData():getPixel(j, row_idx)
                table.insert(colors, rgb2grey(r, g, b))
            end

            if not all_white(colors) then
                white_columns[i] = nil
                goto white_column_removed
            end
        end
        ::white_column_removed::
    end

    -- Set an initial Component to begin at x coordinate 0.
    local component_edges = {0}
    for i, col in pairs(white_columns) do
        if col ~= nil then
            table.insert(component_edges, col)
        end
    end

    table.insert(component_edges, self.image:getWidth() - 1)

    for i=1, #component_edges do
        if  i ~= #component_edges and component_edges[i+1] - component_edges[i] > 2 then
            table.insert(self.components, Entities.Component(component_edges[i], component_edges[i+1], self))
        end
    end

    if next(self.components) == nil then
        table.insert(self.components, Entities.Component(0, self.image:getWidth() - 1, self))
    end
end

-- check_every_cluster_member:
-- Checks whether a cluster member (i.e. Prototype) is part of this
-- Segment. Called by `Segment:recognize()'.
local function check_every_cluster_member(cluster, component, i)
    for cluster_idx=1, math.min(5, #cluster) do
        local member = cluster[math.random(1, #cluster)]
        if image_fits_image(member.image, component.image) then
            if config.DEBUG then print("Checking component", i, "with MEMBER IMAGE", member.string) end

            local ratio, split_x = component:overlay({image_bw = member.image_bw, string = member.string})
            local split_threshold

            if config.high_confidence[member.string] then
                split_threshold = config.HIGH_SPLIT_THRESHOLD
            else
                split_threshold = config.SPLIT_THRESHOLD
            end
            if config.very_high_confidence[member.string] then split_threshold = config.VERY_HIGH_SPLIT_THRESHOLD end

            if ratio >= split_threshold then
                component:split(split_x, split_x + member.image:getWidth(), member.string)
                print("Splitting component", i, "with", member.string, pre_string, "->", tostring(self))
                return true

            elseif ratio < split_threshold and ratio >= 0.75 then
                local letter, _ = max_pair(component.letter_frequencies)
                if member.string == letter then
                    component:split(split_x, split_x + member.image:getWidth(), member.string)
                    print("Splitting component", i, "with", member.string, pre_string, "->", tostring(self))
                    return true
                end
            end
        end
    end

    return false
end

-- overlay_with_cluster_image:
-- Checks whether a cluster image is part of this Segment.
-- Called by `Segment:recognize()'.
local function overlay_with_cluster_image(prototype, component, i)
    if image_fits_image(prototype.image_bw, component.image) then
        if config.DEBUG then print("Checking component", i, "with CLUSTER IMAGE", prototype.string) end

        local ratio, split_x = component:overlay(prototype)
        local split_threshold

        if config.high_confidence[prototype.string] then
            split_threshold = config.HIGH_SPLIT_THRESHOLD
        else
            split_threshold = config.SPLIT_THRESHOLD
        end
        if config.very_high_confidence[prototype.string] then split_threshold = config.VERY_HIGH_SPLIT_THRESHOLD end

        if ratio >= split_threshold then
            component:split(split_x, split_x + prototype.image_bw:getWidth(), prototype.string)

            return true

        elseif ratio < split_threshold and ratio >= split_threshold - 0.05 then
            local letter, _ = max_pair(component.letter_frequencies)
            if prototype.string == letter then
                component:split(split_x, split_x + prototype.image_bw:getWidth(), prototype.string)

                return true
            end

            return check_every_cluster_member(PROTOTYPES.clusters[prototype.string], component, i)

        elseif ratio < split_threshold - 0.05 and ratio >= split_threshold - 0.1 and #PROTOTYPES.clusters[prototype.string] > 1 then
            return check_every_cluster_member(PROTOTYPES.clusters[prototype.string], component, i)
        end
    end

    return false
end

-- Segment:recognize:
-- Attemps to recognize a Segment by checking which Prototypes are part
-- of it. Pardon that messy code, it's not structured very well and
-- has lots of redundancies, but for the evaluation, I needed to set up
-- a function like that ... I try my best describe each step.
function Entities.Segment:recognize ()

    -- First of all, set up a `repeat ... while' loop that gets exited
    -- when no new Prototype has been found in this Segment.
    repeat
        -- Save the string of this Segment BEFORE recognition, so that
        -- it can be compared to the string AFTER recognition.
        local pre_string = tostring(self)
        local component

        -- Check every Component for Prototypes ...
        for i=1, #self.components do
            local component = self.components[i]

            -- ... but only if it hasn't been recognized yet.
            if config.UNKNOWN_COMPONENTS[component.string] then

                -- Get the list of all available, unique Prototypes.
                for prototype in PROTOTYPES:uniquePrototypes() do

                    -- See whether a cluster image for this Prototype exists ...
                    if  PROTOTYPES.clusters[prototype]._image then
                        -- ... and whether it fits into this Component
                        if image_fits_image(PROTOTYPES.clusters[prototype]._image, component.image) then
                            -- If yes, try to find this Prototype (from line 305)
                            local did_split = overlay_with_cluster_image({image_bw = PROTOTYPES.clusters[prototype]._image, string = prototype}, component, i)
                            if did_split then
                                print("Splitting component", i, "with", prototype, pre_string, "->", tostring(self))
                                goto continue
                            end
                        -- If it doesn't fit, iterate over all Prototypes in that cluster
                        else
                            local did_split = check_every_cluster_member(PROTOTYPES.clusters[prototype], component, i)
                            if did_split then
                                print("Splitting component", i, "with", prototype, pre_string, "->", tostring(self))
                                goto continue
                            end
                        end
                    -- If no cluster image exists, iterate over all Prototypes in that cluster
                    else
                        local did_split = check_every_cluster_member(PROTOTYPES.clusters[prototype], component, i)
                        if did_split then
                            print("Splitting component", i, "with", prototype, pre_string, "->", tostring(self))
                            goto continue
                        end
                    end
                end
            end
        end

    ::continue::
    -- TODO: There is a bug in this abort condition. Sometimes it
    --       cancels recognition, even though there are still Components
    --       that can be recognized.
    until pre_string == tostring(self)
end


-- Creates a `Component' entity. A Component represents a small part of
-- a word, containing any amount of letters, but at least 1.
-- @params:  start: Beginning of the Component (x axis)
--           |__@type: number
--           e: End of the Component (x axis)
--           |__@type: number
--           parent: Which Segment this Component is part of
--           |__@type: Segment *
-- @returns: @type: Component
Entities.Component = class("Component")
function Entities.Component:init (start, e, parent)
    self.parent = parent
    self.isComponent = true
    self.range = {start, e}
    self.string = ".+"
    self.letter_frequencies = {}

    local width = e - start + 1
    local height = parent.size.height
    local image_data = love.image.newImageData(width, height)
    image_data:paste(parent.image:getData(), 0, 0, start, 0, width, height)
    self.image = love.graphics.newImage(image_data)
    self.image_bw = threshold_image(self.image)

    -- TODO: Write function that checks whether a component consists
    --       of a single character or more than one.
    if width <= 35 then self.string = "." end

    getmetatable(self).__tostring = function (t)
        return t.string
    end

    WORLD:addEntity(self)
end

-- Component:split:
-- Splits a Component into smaller ones.
-- @params:  start: The beginning of the split
--           |__@type: number
--           e: The end of the split
--           |__@type: number
--           str: The letter this Component shall contain after splitting
--           |__@type: string
-- @returns:
function Entities.Component:split (start, e, str)
    local width = self.range[2] - self.range[1] + 1
    local start = math.max(0, start)
    local e = math.min(e, width)

    local new_components = {}

    if start >= config.MINIMUM_COMPONENT_WIDTH then
        table.insert(new_components, Entities.Component(self.range[1], self.range[1] + start, self.parent))
    end

    local middle_component = Entities.Component(self.range[1] + start, self.range[1] + e, self.parent)
    middle_component.string = str
    table.insert(new_components, middle_component)

    if math.abs(self.range[2] - self.range[1] - e) >= config.MINIMUM_COMPONENT_WIDTH then
        table.insert(new_components, Entities.Component(self.range[1] + e, self.range[2], self.parent))
    end

    local index = invert_table(self.parent.components)[self]
    WORLD:removeEntity(self)
    table.remove(self.parent.components, index)

    for i=1, #new_components do
        table.insert(self.parent.components, index + i - 1, new_components[i])
    end

    -- create a new Prototype from the recognized component (the middle
    -- one)
    if str then
        Entities.Prototype(middle_component.string, middle_component.image)
    end
end


-- Component:overlay:
-- Checks the similarity of this Component's image with another Entity.
-- The entity at least has to provide an `image_bw', that is, a binary
-- image.
-- Returns the x coordinate of the point where the two images are the
-- most similar.
--
-- @params:  prototype: The Entity whose image to check
--           |__@type: (id)
-- @returns: max_ratio: The highest similarity value
--           |__@type: number
--           split_x: The x coordinate where the two Entities are the
--           |        most similar
--           |__@type: number
function Entities.Component:overlay (prototype)
    assert(prototype.image_bw)
    -- assert(prototype.string)

    local sub_image = prototype.image_bw
    local image = self.image_bw

    assert(image:getWidth() >= sub_image:getWidth(), "too large")
    assert(image:getHeight() >= sub_image:getHeight(), "too high")

    local ratios = {}
    -- How many times the smaller image can be shifted over the larger
    -- ones in x/y direction (per pixel)
    local max_y = image:getHeight() - sub_image:getHeight() + 1
    local max_x = image:getWidth() - sub_image:getWidth() + 1

    local image_data = image:getData()
    local sub_image_data = sub_image:getData()
    local sub_width, sub_height = sub_image:getWidth(), sub_image:getHeight()


    for img_y=0, max_y - 1 do
        for img_x=0, max_x - 1 do

            local sum_and, sum_or = 0, 0

            for sub_y=0, sub_height - 1 do
                for sub_x=0, sub_width - 1 do
                    local image_pixel = image:getData():getPixel(img_x+sub_x, img_y+sub_y)
                    local sub_image_pixel = sub_image:getData():getPixel(sub_x, sub_y)

                    -- Let black pixels be evaluated to `1' and white
                    -- pixels to `0' (ref. "Character Segmentation
                    -- Using Visual Inter-word Constraints in a Text
                    -- Page", p. 5)
                    if image_pixel == 255 then
                        image_pixel = 0
                    else
                        image_pixel = 1
                    end

                    if sub_image_pixel == 255 then
                        sub_image_pixel = 0
                    else
                        sub_image_pixel = 1
                    end

                    sum_and = sum_and + bit.band(image_pixel, sub_image_pixel)
                    sum_or = sum_or + bit.bor(image_pixel, sub_image_pixel)

                end
            end
            table.insert(ratios, sum_and/sum_or)
        end
    end

    -- Get the position of the highest ratio
    local max_ratio_index, max_ratio = max_pair(ratios)
    -- IMPORTANT:
    -- From `max_ratio_index', 1 needs to be subtracted because the
    -- `ratios' tables starts indexing at 1 while the ImageData table
    -- (used in `:getData()') starts indexing at 0!
    max_ratio_index = max_ratio_index - 1

    -- The x coordinate where the highest similarity is
    local split_x = max_ratio_index % max_x

    if config.DEBUG then
        print("Overlaying:", prototype.string, max_ratio_index, max_ratio,
                             split_x, split_x + sub_image:getWidth() - 1)
    end

    return max_ratio, split_x
end

return Entities