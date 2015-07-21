local SPLIT_THRESHOLD = 0.65
local START = '^'
local END = '$'
local UNKNOWN_COMPONENT = '.*'
local -- STANDARD_COLOR = (0, 0, 0)
local MINIMUM_COMPONENT_WIDTH = 4

local Components = {}

function Components.threshold(tensor):
    tensor:apply(function (x) if x >= 0.5 then return 1.0 else return 0 end)
end

function Components.compare_image_region(image, sub_image)
    assert(image:size()[2] == sub_image:size()[2])
    assert(image:size()[3] == sub_image:size()[3])

    local nom = 0
    local denom = 0

    image_bw = threshold(image:clone())
    sub_image_bw = threshold(sub_image:clone())
end

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

    def to_string(self):
        """
        """

        return ''.join(str(comp) for comp in self)

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

    def iterate_components(self, reverse=False):
        """
        """

        for comp in self:
            if isinstance(comp, Component):
                yield comp

        if reverse:
            for comp in self[::-1]:
                if isinstance(comp, Component):
                    yield comp

    def print_components(self):
        """
        """

        for comp in self.iterate_components():
            print comp.begin, comp.end

    def _split_at(self, min_x, max_x, prototype=None):
        """
        """

        assert min_x in range(self.width() + 1) and max_x in range(self.width() + 1)
        assert max_x - min_x >= MINIMUM_COMPONENT_WIDTH


        affected_components = []
        for i, comp in enumerate(self):
            if isinstance(comp, Prototype):
                continue

            if min_x in range(comp.begin, comp.end) or max_x in range(comp.begin, comp.end):
                affected_components.append(i)

        print affected_components

        # component_ranges = [(x.begin, x.end) for x in self if isinstance(x, Component)]

        # print component_ranges

        # affected_components = []
        # for i, comp in enumerate(component_ranges):
        #     if min_x in range(comp[0], comp[1]) or max_x in range(comp[0], comp[1]):
        #         affected_components.append(i)

        # print affected_components

        left_component = self[affected_components[0]]
        right_component = self[affected_components[-1]]

        for i in affected_components:
            self.pop(i)


        new_components = []
        if abs(left_component.begin - min_x) >= MINIMUM_COMPONENT_WIDTH:
            new_components.append(Component(self, left_component.begin, min_x))

        if prototype is not None:
            new_components.append(prototype)
        else:
            new_components.append(Component(self, min_x, max_x))

        if abs(right_component.end - max_x) >= MINIMUM_COMPONENT_WIDTH:
            new_components.append(Component(self, max_x, right_component.end))

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


class Component(object):
    """

    """

    def __init__(self, word, min_x, max_x, prototype=None):
        """
        """

        self.begin = min_x
        self.end = max_x
        self.width = max_x - min_x
        self.image = word.create_sub_image(min_x, max_x)
        self.prototype = prototype

    def find_prototype_region(self, prototype):
        """
        """

        # assert self.image.shape >= prototype.image.shape

        if self.image.shape[1] < prototype.image.shape[1]:
            prototype_image = prototype.resize_to_width(self.image.shape[1])
        else:
            prototype_image = prototype.image


        ratio_shape = (self.image.shape[0] - prototype_image.shape[0] + 1,
                       self.image.shape[1] - prototype_image.shape[1] + 1)

        ratios = np.zeros(ratio_shape)

        if self.image.shape == prototype_image.shape:
            ratios[0, 0] = compare_image_region(self.image, prototype_image)
            return ratios


        for i in range(self.image.shape[0] - prototype_image.shape[0] + 1):
            for j in range(self.image.shape[1] - prototype_image.shape[1] + 1):
                cropped_image = self.image[i:i + prototype_image.shape[0], j:j + prototype_image.shape[1]]
                # ratios[i].append(compare_image_region(cropped_image, prototype_image))
                ratios[i, j] = compare_image_region(cropped_image, prototype_image)

        return ratios

    def __repr__(self):
        return self.__str__()

    def __str__(self):
        """
        """

        if self.prototype is not None:
            return self.prototype

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

    def resize_to_width(self, width, keep_aspect_ratio=False):
        """
        """

        if keep_aspect_ratio:
            aspect_ratio = self.image.shape[0]/self.image.shape[1]
            height = aspect_ratio * width
            return cv2.resize(self.image, (width, height))
        else:
            return cv2.resize(self.image, (width, self.image.shape[0]))


e = Prototype.from_image_file('e', '../share/e.png')
ch = Prototype.from_image_file('ch', '../share/ch.png')
img = cv2.imread('../share/ausschnitt.png', 0)
indessen = Word(img, ((14, 2), (199, 64)))
etliche = Word(img, ((432, 5), (550, 55)))

return Components