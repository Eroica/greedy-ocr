local Prototype = {}

function Prototype:height ()
    return self._image:size(2)
end

function Prototype:width ()
    return self._image:size(3)
end

function Prototype:__tostring ()
    return self._string
end

function Prototype:new (_image, string)
    local prototype = {}

    setmetatable(prototype, self)
    self.__index = self

    prototype._image = _image
    prototype._string = string

    return prototype
end

function Prototype:new_from_image_file (filename, string)
    return Prototype:new(image.load(filename, 1), string)
end

function Prototype:copy_and_resize (width, height)
    return image.scale(self._image, width, height)
end

return Prototype