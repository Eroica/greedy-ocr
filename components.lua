--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    components.lua

]]

-- Identity Components:
-- These components serve to distinguish entities by an `identity.'
-- A `Component' entity cannot be a `Segment' or `Prototype' entity,
-- and vice versa.
isLine = class("isLine", Component)
function isLine:__init () end

isNotRecognized = class("isNotRecognized", Component)
function isNotRecognized:__init () end

isSegment = class("isSegment", Component)
function isSegment:__init () end

isComponent = class("isComponent", Component)
function isComponent:__init () end

isPrototype = class("isPrototype", Component)
function isPrototype:__init () end


-- Position Component:
-- Used to hold a position, most of the time in world coordinates.
Position = class("Position", Component)
function Position:__init (l, t)
    self.l = l
    self.t = t
end

-- Size Component:
-- Used to hold a size attribute---for instance, the width of Segments.
Size = class("Size", Component)
function Size:__init (width, height)
    self.width = width
    self.height = height
end

-- Image Component:
-- Holds an image (in Love2D's `Image' format). In addition, a binary
-- image is created whenever this component is attached to an entity.
Image = class("Image", Component)
function Image:__init (image)
    -- Create the binary image
    local image_bw_data = love.image.newImageData(image:getWidth(), image:getHeight())
    image_bw_data:paste(image:getData(), 0, 0, 0, 0, image:getWidth(), image:getHeight())
    image_bw_data:mapPixel(threshold())
    local image_bw = love.graphics.newImage(image_bw_data)

    self.image = image
    self.image_bw = image_bw
end

-- Range Component:
-- Used to specify when a Component entity begins and where it ends
-- (in Segment coordinates).
Range = class("Range", Component)
function Range:__init (start, e)
    self.s = start
    self.e = e
end

-- String Component:
-- Holds a string for Components or Prototypes.
String = class("String", Component)
function String:__init (literal)
    self.string = literal or ".*"
end