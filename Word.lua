local Word = {}

function Word:height()
    return self._image:size()[2]
end

function Word:width()
    return self._image:size()[3]
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

function Word:split ()
    local image_bw = self._image:clone():apply(threshold)
    local columns = {}
    local find_white = true

    for i=1, self:width() do
        if find_white then
            if image_bw[{1, {}, i}]:eq(1):all() then
                goto continue
            else
                columns[#columns + 1] = i
                find_white = false
            end
        else
            if image_bw[{1, {}, i}]:eq(0):any() then
                goto continue
            else
                columns[#columns + 1] = i
                find_white = true
            end
        end
        ::continue::
    end

    return columns
end



function Word:_split_at (s, e)
    s = math.max(0, s)
    e = math.min(self:width(), e)

    assert(e - s > 0)

    affected_components = {}
    for i=1, #self do
        if tostring(self[i]) ~= ".*" then
            goto continue
        end

        if ((self[i].s <= s) and (s <= self[i].e))
        or ((self[i].s <= e) and (e <= self[i].e)) then
            table.insert(affected_components, i)
        end

        ::continue::
    end

    print(affected_components)
end

return Word

--     def to_string(self):
--         """
--         """

--         return ''.join(str(comp) for comp in self)


--         # component_ranges = [(x.begin, x.end) for x in self if isinstance(x, Component)]

--         # print component_ranges

--         # affected_components = []
--         # for i, comp in enumerate(component_ranges):
--         #     if min_x in range(comp[0], comp[1]) or max_x in range(comp[0], comp[1]):
--         #         affected_components.append(i)

--         # print affected_components

--         left_component = self[affected_components[0]]
--         right_component = self[affected_components[-1]]

--         for i in affected_components:
--             self.pop(i)


--         new_components = []
--         if abs(left_component.begin - min_x) >= MINIMUM_COMPONENT_WIDTH:
--             new_components.append(Component(self, left_component.begin, min_x))

--         if prototype is not None:
--             new_components.append(prototype)
--         else:
--             new_components.append(Component(self, min_x, max_x))

--         if abs(right_component.end - max_x) >= MINIMUM_COMPONENT_WIDTH:
--             new_components.append(Component(self, max_x, right_component.end))

--         self[affected_components[0]:affected_components[0]] = new_components



--     def _split_at(self, min_x, max_x, prototype=None):
--         """
--         """

--         assert min_x in range(self.width() + 1) and max_x in range(self.width() + 1)
--         assert max_x - min_x >= MINIMUM_COMPONENT_WIDTH


--         affected_components = []
--         for i, comp in enumerate(self):
--             if isinstance(comp, Prototype):
--                 continue

--             if min_x in range(comp.begin, comp.end) or max_x in range(comp.begin, comp.end):
--                 affected_components.append(i)

--         print affected_components

--         # component_ranges = [(x.begin, x.end) for x in self if isinstance(x, Component)]

--         # print component_ranges

--         # affected_components = []
--         # for i, comp in enumerate(component_ranges):
--         #     if min_x in range(comp[0], comp[1]) or max_x in range(comp[0], comp[1]):
--         #         affected_components.append(i)

--         # print affected_components

--         left_component = self[affected_components[0]]
--         right_component = self[affected_components[-1]]

--         for i in affected_components:
--             self.pop(i)


--         new_components = []
--         if abs(left_component.begin - min_x) >= MINIMUM_COMPONENT_WIDTH:
--             new_components.append(Component(self, left_component.begin, min_x))

--         if prototype is not None:
--             new_components.append(prototype)
--         else:
--             new_components.append(Component(self, min_x, max_x))

--         if abs(right_component.end - max_x) >= MINIMUM_COMPONENT_WIDTH:
--             new_components.append(Component(self, max_x, right_component.end))

--         self[affected_components[0]:affected_components[0]] = new_components

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
