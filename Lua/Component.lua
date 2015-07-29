local Component = {}

function Component:height ()
    return self._image:size(2)
end

function Component:width ()
    return self._image:size(3)
end

-- function Component:__tostring ()
--     return self._string
-- end

function Component:new (word, start, e)
    local component = {}

    setmetatable(component, self)
    self.__index = self

    component.s = start
    component.e = e

    -- Create image for component with size of e - start + 1
    --      start: begin of component
    --      e: end of component
    -- + 1 needs to be added because of the fencepost error
    component._image = word._image:narrow(3, start, e - start + 1)
    component._string = UNKNOWN_COMPONENT

    return component
end

function Component:find_prototype_region (prototype)
    local prototype_image

    if self:height() < prototype:height() or self:width() < prototype:width() then
        prototype_image = prototype:copy_and_resize(self:width(), self:height()):apply(threshold)
    else
        prototype_image = prototype._image:clone():apply(threshold)
    end

    local ratios = torch.Tensor(self:height() - prototype_image:size(2) + 1,
                                self:width() - prototype_image:size(3) + 1)

    local component_image = self._image:clone():apply(threshold)

    for i=1, ratios:size(1) do
        for j=1, ratios:size(2) do
            local cropped_image = component_image:narrow(2, i, prototype_image:size(2))
                                                 :narrow(3, j, prototype_image:size(3))

            ratios[{i, j}] = compare_image_region(cropped_image, prototype_image)
        end
    end

    -- return ratios
    -- Looks for the coordinate with the highest value and returns its
    -- index
    for i=1, ratios:size(1) do
        for j=1, ratios:size(2) do
            if ratios[i][j] == ratios:max() then
                return i, j, ratios:max()
            end
        end
    end
end

return Component