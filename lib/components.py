import numpy as np
import cv2
import otf

SPLIT_THRESHOLD = 0.65
START = '^'
END = '$'
UNKNOWN_COMPONENT = '.*'
STANDARD_COLOR = (0, 0, 0)
MINIMUM_COMPONENT_WIDTH = 4

def threshold_image(image):
    """
    """

    (thresh, im_bw) = cv2.threshold(image, 128, 255, cv2.THRESH_BINARY)
    return im_bw

def compare_image_region(image, sub_image):
    """
    """

    assert image.shape == sub_image.shape

    nom = 0
    denom = 0

    image_bw = threshold_image(image)
    sub_image_bw = threshold_image(sub_image)

    for i in range(sub_image_bw.shape[0]):
        for j in range(sub_image_bw.shape[1]):
            nom += image_bw[i, j] and sub_image_bw[i, j]
            denom += image_bw[i, j] or sub_image_bw[i, j]

    ratio = nom/float(denom)

    return ratio





class Word(list):
    """

    """

    def __init__(self, image, box=((0, 0), (0, 0))):
        """
        """

        super(Word, self).__init__()

        point_1 = box[0]
        point_2 = box[1]

        self.image = image[point_1[1]:point_2[1], point_1[0]:point_2[0]]
        self.bounding_box = box

        self.append(Component(self, 0, self.image.shape[1]))

    def height(self):
        """
        """

        return self.image.shape[0]

    def width(self):
        """
        """

        return self.image.shape[1]

    def draw_components(self):
        """
        """

        components_image = self.image.copy()

        for comp in self:
            if isinstance(comp, Component):
                cv2.line(components_image, (comp.begin, 0), (comp.begin, self.height()), STANDARD_COLOR)
                cv2.line(components_image, (comp.end - 1, 0), (comp.end - 1, self.height()), STANDARD_COLOR)

        return components_image

    def create_sub_image(self, min_x, max_x):
        """
        """

        assert min_x <= self.width() and max_x <= self.width()

        sub_image = self.image[0:self.height(), min_x:max_x]

        return sub_image

    def _split_at(self, min_x, max_x, with_prototype=None):
        """
        """

        assert min_x in range(self.width()) and max_x in range(self.width())

        component_ranges = [(x.begin, x.end) for x in self if isinstance(x, Component)]

        affected_components = []
        for i, comp in enumerate(component_ranges):
            if min_x in range(comp[0], comp[1]) or max_x in range(comp[0], comp[1]):
                affected_components.append(i)

        left_component = self[affected_components[0]]
        right_component = self[affected_components[-1]]

        for i in affected_components:
            self.pop(i)


        if abs(left_component.begin - min_x) >= MINIMUM_COMPONENT_WIDTH:
            self.insert(affected_components[0], Component(self, left_component.begin, min_x))

        self.insert(affected_components[0] + 1, Component(self, min_x, max_x))

        if abs(right_component.end - max_x) >= MINIMUM_COMPONENT_WIDTH:
            self.insert(affected_components[0] + 2, Component(self, max_x, right_component.end))

    def split_with(self, prototype):
        """
        """

        max_ratio = 0
        max_ratio_index = 0
        max_comp_index = 0
        ratio_shape = (0, 0)

        for i, comp in enumerate(self):
            if isinstance(comp, Component):
                ratios = comp.find_prototype_region(prototype)

                if ratios.max() > max_ratio and ratios.max() >= SPLIT_THRESHOLD:
                    max_ratio = ratios.max()
                    max_ratio_index = ratios.argmax()
                    max_comp_index = i
                    ratio_shape = ratios.shape

        if ratio_shape == (0, 0):
            return

        split_coords = (max_ratio_index / ratio_shape[1],
                        max_ratio_index % ratio_shape[1])

        component_ranges = [(x.begin, x.end) for x in self if isinstance(x, Component)]

        affected_components = []

        for i, comp in enumerate(component_ranges):
            if split_coords[1] in range(comp[0], comp[1]) or split_coords[1] + prototype.image.shape[1] in range(comp[0], comp[1]):
                affected_components.append(i)

        left_component = self[affected_components[0]]
        right_component = self[affected_components[-1]]

        for i in affected_components:
            self.pop(i)

        self.insert(affected_components[0], Component(self, left_component.begin, split_coords[1]))
        self.insert(affected_components[0] + 1, prototype)
        self.insert(affected_components[0] + 2, Component(self, split_coords[1] + prototype.image.shape[1], right_component.end))

        # left_component = Component(self, 0, split_coords[1] - 1)
        # right_component = Component(self,
        #                             split_coords[1] + prototype.image.shape[1],
        #                             split_coords[1] + prototype.image.shape[1] + self[max_comp_index].end)

        # # print right_component.box

        # self.pop(max_comp_index)
        # self.insert(max_comp_index, left_component)
        # self.insert(max_comp_index + 1, prototype)
        # self.insert(max_comp_index + 2, right_component)


class Component(object):
    """

    """

    def __init__(self, word, min_x, max_x):
        """
        """

        self.begin = min_x
        self.end = max_x
        # self.word = word
        self.width = max_x - min_x
        # self.box = ((min_x, 0), (self.width, self.word.height()))
        # self.image = word.create_sub_image(self.box)
        self.image = word.create_sub_image(min_x, max_x)

    def find_prototype_region(self, prototype):
        """
        """

        assert self.image.shape >= prototype.image.shape

        ratio_shape = (self.image.shape[0] - prototype.image.shape[0] + 1,
                       self.image.shape[1] - prototype.image.shape[1] + 1)

        if self.image.shape[1] - prototype.image.shape[1] + 1 == 0:
            print self.image.shape[1]
            print prototype.image.shape[1]

        print "region ratio_shape " + str(ratio_shape)

        ratios = np.zeros(ratio_shape)

        if self.image.shape == prototype.image.shape:
            ratios[0, 0] = compare_image_region(self.image, prototype.image)
            return ratios


        for i in range(self.image.shape[0] - prototype.image.shape[0] + 1):
            for j in range(self.image.shape[1] - prototype.image.shape[1] + 1):
                cropped_image = self.image[i:i + prototype.image.shape[0], j:j + prototype.image.shape[1]]
                # ratios[i].append(compare_image_region(cropped_image, prototype.image))
                ratios[i, j] = compare_image_region(cropped_image, prototype.image)

        return ratios


    # def overlay_with(self, component):
    #     """
    #     """

    #     image = self.word.create_sub_image(self.box)
    #     sub_image = component.word.create_sub_image(component.box)

    #     assert image.shape >= sub_image.shape

    #     if image.shape == sub_image.shape:
    #         return [compare_image_region(image, sub_image)]

    #     # ratios = [[] for _ in range(image.shape[0])]
    #     ratio_shape = (image.shape[0] - sub_image.shape[0] + 1,
    #                    image.shape[1] - sub_image.shape[1] + 1)
    #     ratios = np.zeros(ratio_shape)

    #     for i in range(image.shape[0] - sub_image.shape[0] + 1):
    #         for j in range(image.shape[1] - sub_image.shape[1] + 1):
    #             cropped_image = image[i:i + sub_image.shape[0], j:j + sub_image.shape[1]]
    #             # ratios[i].append(compare_image_region(cropped_image, sub_image))
    #             ratios[i, j] = compare_image_region(cropped_image, sub_image)

    #     return ratios

    # def translate_index(self, index):
    #     """
    #     """

    #     return (index/self.width, index % self.width)

    def __repr__(self):
        return self.__str__()

    def __str__(self):
        """
        """

        return UNKNOWN_COMPONENT


class Prototype(str):
    """

    """

    _default_image = None

    def __new__(cls, characters, image=_default_image):
        """
        """

        return super(Prototype, cls).__new__(cls, str(characters))

    def __init__(self, characters, image=_default_image):
        """
        """

        self.image = image

    @classmethod
    def from_image_file(cls, characters, image_file):
        """
        """

        assert isinstance(image_file, str)
        image = cv2.imread(image_file, 0)

        return cls(characters, image)

    def resize_to_width(self, width):
        """
        """

        aspect_ratio = self.image.shape[0]/self.image.shape[1]

        height = aspect_ratio * width

        return cv2.resize(self.image, (width, height))

e = Prototype.from_image_file('e', '../share/e.png')
ch = Prototype.from_image_file('ch', '../share/ch.png')
img = cv2.imread('../share/ausschnitt.png', 0)
indessen = Word(img, ((14, 2), (199, 64)))
etliche = Word(img, ((432, 5), (550, 55)))