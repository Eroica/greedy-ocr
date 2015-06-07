#include <stdio.h>
#include <assert.h>
#include <opencv/highgui.h>
#include "vector.h"
#include "text_detection.h"
#include "component_analysis.h"

int
mainTextDetection(int argc, char *argv[]) {
    IplImage *input_image = cvLoadImage(argv[1], CV_LOAD_IMAGE_COLOR);

    if(!input_image) {
        printf("couldn't load query image\n");
        return -1;
    }

    // Detect text in the image
    IplImage *output = text_detection(input_image, atoi(argv[3]));
    cvReleaseImage(&input_image);
    cvSaveImage(argv[2], output, 0);
    cvReleaseImage(&output);

    return 0;
}

int
main(int argc, char *argv[]) {
    if((argc != 4)) {
        printf ( "usage: %s imagefile resultImage darkText\n", argv[0] );
        return -1;
    }

    return mainTextDetection ( argc, argv );
}
