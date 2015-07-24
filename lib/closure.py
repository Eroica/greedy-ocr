import numpy as np
import cv2

def linefy_image(image):
    count = []
    find_white = True

    for line in range(0, image.shape[0]):
        if find_white:
            if all(i.all() == 0 for i in image[line,:]):
                continue
            else:
                count.append(line)
                find_white = False
        else:
            if any(i.any() != 0 for i in image[line,:]):
                continue
            else:
                count.append(line)
                find_white = True


    return count

def show_lines(image, count):
    for i, _ in enumerate(count):
        sub_image = image[count[i]:count[i+1],:]
        cv2.imshow("sub", sub_image)
        cv2.waitKey(0)