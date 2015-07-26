local Word = {}

function Word:height ()
    return self._image:size(2)
end

function Word:width ()
    return self._image:size(3)
end

function Word:new (_image, bounding_box)
    local top_left = {bounding_box[1] or 0, bounding_box[2] or 0}
    local bottom_right = {bounding_box[3] or 0, bounding_box[4] or 0}

    local word = {}
    setmetatable(word, self)
    self.__index = self

    word._image = _image:narrow(2, top_left[2], bottom_right[2] - top_left[2])
                        :narrow(3, top_left[1], bottom_right[1] - top_left[1])
    word._bounding_box = bounding_box

    table.insert(word, Component:new(word, 1, word:width()))

    return word
end

function Word:__tostring ()
    local str = {}

    for i=1, #self do
        string[#string + 1] = tostring(self[i])
    end

    return table.concat(string)
end


-- function Word:split_into_components ()
--     local image_bw = self._image:clone():apply(threshold)
--     local columns = {}
--     local find_white = true

--     for i=1, self:width() do
--         if find_white then
--             if image_bw[{1, {}, i}]:eq(1):all() then
--                 goto continue
--             else
--                 columns[#columns + 1] = i
--                 find_white = false
--             end
--         else
--             if image_bw[{1, {}, i}]:eq(0):any() then
--                 goto continue
--             else
--                 columns[#columns + 1] = i
--                 find_white = true
--             end
--         end
--         ::continue::
--     end

--     for i=1, #columns, 2 do
--         local e = columns[i+1] or self:width()

--         -- table.insert(self, Component:new(columns[i], e))
--     end
--     return columns
-- end



function Word:_split_at (s, e)
    local s = math.max(0, s)
    local e = math.min(self:width(), e)

    assert(e - s > 0)

    local affected_components = {}
    for i=1, #self do
        local comp = self[i]

        if tostring(comp) ~= ".*" then
            goto continue
        end

        -- check if component is part of split area
        if ((comp.s >= s and comp.s <= e) or (comp.e >= s and comp.e <= e))
        -- check if split area is part of component
        or ((comp.s <= s and s <= comp.e) or (comp.s <= e and e <= comp.e)) then
            table.insert(affected_components, i)
        end

        ::continue::
    end

    local left_component = self[affected_components[1]]
    local right_component = self[affected_components[#affected_components]]

    for i=#affected_components, 1, -1 do
        table.remove(self, affected_components[i])
    end

    local new_components = {}
    if math.abs(left_component.s - s) >= MINIMUM_COMPONENT_WIDTH then
        table.insert(new_components, Component:new(self, left_component.s, s))
    end

    table.insert(new_components, Component:new(self, s, e))

    if math.abs(right_component.e - e) >= MINIMUM_COMPONENT_WIDTH then
        table.insert(new_components, Component:new(self, e, right_component.e))
    end

    for i=1, #new_components do
        table.insert(self, affected_components[1] + i - 1, new_components[i])
    end
end

return Word




-- function Word:find_prototype(prototype)


--     def split_with(self, prototype):
--         """
--         """

--         max_ratio = 0
--         max_ratio_index = 0
--         max_comp_index = 0
--         ratio_shape = (0, 0)
--         ratios = 0

--         for i, comp in enumerate(self):

--             if isinstance(comp, Component):
--                 print "checking component " + str(i)
--                 ratios = comp.find_prototype_region(prototype).copy()

--                 if ratios.max() > max_ratio and ratios.max() >= SPLIT_THRESHOLD:
--                     print ratios.max()
--                     max_ratio = ratios.max()
--                     max_ratio_index = ratios.argmax()
--                     max_comp_index = i
--                     ratio_shape = ratios.shape

--         if ratio_shape == (0, 0):
--             return


--         split_coords = (max_ratio_index / ratio_shape[1],
--                         max_ratio_index % ratio_shape[1])

--         min_x = self[max_comp_index].begin + split_coords[1] - 1
--         max_x = self[max_comp_index].begin + split_coords[1] + prototype.image.shape[1] - 1
--         if min_x < 0:
--             min_x = 0

--         self._split_at(min_x, max_x, prototype)

--         # self._split_at(self[max_comp_index].begin + split_coords[1], self[max_comp_index].begin + split_coords[1] + prototype.image.shape[1], prototype)
