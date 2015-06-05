#include <stdio.h>
#include <assert.h>
#include <opencv/highgui.h>
#include "vector.h"
#include "text_detection.h"


IplImage * loadByteImage ( const char * name ) {
  IplImage * image = cvLoadImage ( name );

  if ( !image )
  {
    return 0;
  }
  cvCvtColor ( image, image, CV_BGR2RGB );
  return image;
}

int
mainTextDetection(int argc, char *argv[]) {
  // IplImage * input_image = loadByteImage ( argv[1] );

    CvMat *input_image = cvLoadImageM(argv[1])

    if(!input_image) {
        printf("couldn't load query image\n");
        return -1;
    }

    prepare_image(input_image, atoi(argv[3]));

    // Detect text in the image
    // IplImage *output = prepare_image(byteQueryImage, atoi(argv[3]));
    cvReleaseImage(&input_image);
    // cvSaveImage(argv[2], output );
    // cvReleaseImage(&output);
    return 0;
}

int
main(int argc, char argv[]) {
  if((argc != 4)) {
    printf ( "usage: %s imagefile resultImage darkText\n",
             argv[0] );

    return -1;
  }

  return mainTextDetection ( argc, argv );
}
