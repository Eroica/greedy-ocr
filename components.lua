isLine = class("isLine", Component)
function isLine:__init()
end

isSegment = class("isSegment", Component)
function isSegment:__init()
end

isComponent = class("isComponent", Component)
function isComponent:__init()
end


Position = class("Position", Component)
function Position:__init(l, t)
    self.l = l
    self.t = t
end


Size = class("Size", Component)
function Size:__init(width, height)
    self.width = width
    self.height = height
end


Image = class("Image", Component)
function Image:__init(image)
    local image_bw = love.image.newImageData(image:getWidth(), image:getHeight())
    image_bw:paste(image:getData(), 0, 0, 0, 0, image:getWidth(), image:getHeight())
    image_bw:mapPixel(threshold())

    self.image = image
    self.image_bw = image_bw
end


Range = class("Range", Component)
function Range:__init(start, e)
    self.s = start
    self.e = e
end


String = class("String", Component)
function String:__init(literal)
    self.string = literal or ".*"
end