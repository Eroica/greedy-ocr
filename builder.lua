local Image = {}

function Image.new (_image)
    local self = {}
    setmetatable(self, self)
    self._image = _image

    function self.width ()
        return self._image:size(3)
    end

    function self.height ()
        return self._image:size(2)
    end

    return self
end

return Image