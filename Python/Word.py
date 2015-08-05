import cv2

from Component import Component
import gr_config as CONFIG

class Word(list):
    """

    """

    def __init__(self, image, bounding_box):
        """
        """

        super(Word, self).__init__()

        point_1 = bounding_box[0] or (0, 0)
        point_2 = bounding_box[1] or (image.shape[1], image.shape[0])

        self._image = image[point_1[1]:point_2[1], point_1[0]:point_2[0]]
        self._bounding_box = bounding_box
        self._candidates = []

        # subtract 1 because of off-by-one error
        self.append(Component(self, 0, self._image.shape[1] - 1))

    def possible_words(self, lexicon):
        """Queries `lexicon' for the current redacted string and saves
        all possible words into `self._candidates'.
        """

        self._candidates = lexicon.query(self.to_string())

        if len(self._candidates) == 1:
            print "Word successfully recognized as `" + self._candidates[0] + "'"

    def height(self):
        """Returns the height of `self._image', and, by extension, the
        height of the bounding box that encloses this word.
        """

        return self._image.shape[0]

    def width(self):
        """Returns the width of `self._image', and, by extension, the
        width of the bounding box that encloses this word.
        """

        return self._image.shape[1]

    def to_string(self):
        """
        """

        return ''.join(str(comp) for comp in self)

    def image(self):
        """Returns a copy of `self._image' which shows the position
        of all current components.
        """

        components_image = self._image.copy()

        for comp in self.all_components():
            cv2.line(components_image, (comp.begin, 0), (comp.begin, self.height()), CONFIG.STANDARD_COLOR)
            cv2.line(components_image, (comp.end, 0), (comp.end, self.height()), CONFIG.STANDARD_COLOR)

        return components_image

    def crop_image(self, min_x, max_x):
        """Returns a smaller image of self._image, cropped at
        x-coordinates `min_x' and `max_x'.
        Height equals to self.height()
        """

        assert min_x <= self.width() and max_x <= self.width()

        sub_image = self._image[0:self.height(), min_x:max_x]

        return sub_image

    def all_components(self, reverse=False):
        """Iterator for all components in self. Prototypes are ignored.
        """

        if reverse:
            for comp in self[::-1]:
                if isinstance(comp, Component):
                    yield comp
        else:
            for comp in self:
                if isinstance(comp, Component):
                    yield comp

    def print_components(self):
        """Prints a list of all current component of that word.
        Prototypes are ignored.
        """

        for i, comp in enumerate(self.all_components()):
            print i, comp.begin, comp.end


    def _split_at(self, s, e):
        """Takes two x-coordinates and creates a new component there.
        Overlapping components will be shrunken.
        """

        begin = max(0, s)
        end = min(self.width(), e)

        assert (end - begin) > 0

        affected_components = []

        for i, comp in enumerate(self.all_components()):
            if ((comp.begin >= begin and comp.begin <= end) or (comp.end >= begin and comp.end <= end)) \
            or ((comp.begin <= begin and begin <= comp.end) or comp.begin <= end and end <= comp.end):
                affected_components.append(i)

        left_component = self[affected_components[0]]
        right_component = self[affected_components[-1]]

        for i in affected_components[::-1]:
            self.pop(i)

        new_components = []
        if abs(left_component.begin - begin) >= CONFIG.MINIMUM_COMPONENT_WIDTH:
            new_components.append(Component(self, left_component.begin, begin))

        new_components.append(Component(self, begin, end))

        if abs(right_component.end - end) >= CONFIG.MINIMUM_COMPONENT_WIDTH:
            new_components.append(Component(self, end, right_component.end))

        self[affected_components[0]:affected_components[0]] = new_components


    def split_with(self, prototype):
        """
        """

        max_ratio = 0
        max_ratio_index = 0
        max_comp_index = 0
        ratio_shape = (0, 0)
        ratios = 0

        for i, comp in enumerate(self):

            if isinstance(comp, Component):
                print "checking component " + str(i)
                ratios = comp.find_prototype_region(prototype).copy()

                if ratios.max() > max_ratio and ratios.max() >= SPLIT_THRESHOLD:
                    print ratios.max()
                    max_ratio = ratios.max()
                    max_ratio_index = ratios.argmax()
                    max_comp_index = i
                    ratio_shape = ratios.shape

        if ratio_shape == (0, 0):
            return


        split_coords = (max_ratio_index / ratio_shape[1],
                        max_ratio_index % ratio_shape[1])

        min_x = self[max_comp_index].begin + split_coords[1] - 1
        max_x = self[max_comp_index].begin + split_coords[1] + prototype.image.shape[1] - 1
        if min_x < 0:
            min_x = 0

        self._split_at(min_x, max_x, prototype)

        # self._split_at(self[max_comp_index].begin + split_coords[1], self[max_comp_index].begin + split_coords[1] + prototype.image.shape[1], prototype)

