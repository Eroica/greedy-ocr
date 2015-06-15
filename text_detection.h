#ifndef TEXT_DETECTION_H
#define TEXT_DETECTION_H

#include <stdbool.h>
#include <opencv/cv.h>

#ifdef __cplusplus
extern "C" {
#endif

void
extract_letters(IplImage *input_image,
                bool dark_on_light);

#ifdef __cplusplus
}
#endif

#endif // TEXT_DETECTION_H