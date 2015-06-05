#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <opencv/cxcore.h>
#include <math.h>
#include <time.h>
#include "vector.h"
#include "text_detection.h"


void
prepare_image(IplImage *input_image, bool dark_on_light)
{
    assert(input->depth == IPL_DEPTH_8U);
    assert(input->nChannels == 3);

    // Convert to grayscale.
    IplImage *gray_image = cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_8U, 1 );
    cvCvtColor ( input, gray_image, CV_RGB2GRAY );

    // Create Canny Image.
    double threshold_low = 175;
    double threshold_high = 320;
    IplImage * edge_image = cvCreateImage( cvGetSize (input_image),IPL_DEPTH_8U, 1 );
    cvCanny(gray_image, edge_image, threshold_low, threshold_high, 3) ;
    cvSaveImage ( "canny.png", edge_image);

    // Create gradient X, gradient Y
    IplImage * gaussian_image = cvCreateImage ( cvGetSize(input), IPL_DEPTH_32F, 1);
    cvConvertScale (gray_image, gaussian_image, 1./255., 0);
    cvSmooth( gaussian_image, gaussian_image, CV_GAUSSIAN, 5, 5);
    IplImage * gradientX = cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_32F, 1 );
    IplImage * gradientY = cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_32F, 1 );
    cvSobel(gaussian_image, gradientX , 1, 0, CV_SCHARR);
    cvSobel(gaussian_image, gradientY , 0, 1, CV_SCHARR);
    cvSmooth(gradientX, gradientX, 3, 3);
    cvSmooth(gradientY, gradientY, 3, 3);
    cvReleaseImage ( &gaussian_image );
    cvReleaseImage ( &gray_image );


}

IplImage * textDetection (IplImage * input, bool dark_on_light)
{
    assert ( input->depth == IPL_DEPTH_8U );
    assert ( input->nChannels == 3 );
    std::cout << "Running textDetection with dark_on_light " << dark_on_light << std::endl;
    // Convert to grayscale
    IplImage * grayImage =
            cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_8U, 1 );
    cvCvtColor ( input, grayImage, CV_RGB2GRAY );
    // Create Canny Image
    double threshold_low = 175;
    double threshold_high = 320;
    IplImage * edgeImage =
            cvCreateImage( cvGetSize (input),IPL_DEPTH_8U, 1 );
    cvCanny(grayImage, edgeImage, threshold_low, threshold_high, 3) ;
    cvSaveImage ( "canny.png", edgeImage);

    // Create gradient X, gradient Y
    IplImage * gaussianImage =
            cvCreateImage ( cvGetSize(input), IPL_DEPTH_32F, 1);
    cvConvertScale (grayImage, gaussianImage, 1./255., 0);
    cvSmooth( gaussianImage, gaussianImage, CV_GAUSSIAN, 5, 5);
    IplImage * gradientX =
            cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_32F, 1 );
    IplImage * gradientY =
            cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_32F, 1 );
    cvSobel(gaussianImage, gradientX , 1, 0, CV_SCHARR);
    cvSobel(gaussianImage, gradientY , 0, 1, CV_SCHARR);
    cvSmooth(gradientX, gradientX, 3, 3);
    cvSmooth(gradientY, gradientY, 3, 3);
    cvReleaseImage ( &gaussianImage );
    cvReleaseImage ( &grayImage );

    // Calculate SWT and return ray vectors
    std::vector<Ray> rays;
    IplImage * SWTImage =
            cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_32F, 1 );
    for( int row = 0; row < input->height; row++ ){
        float* ptr = (float*)(SWTImage->imageData + row * SWTImage->widthStep);
        for ( int col = 0; col < input->width; col++ ){
            *ptr++ = -1;
        }
    }
    strokeWidthTransform ( edgeImage, gradientX, gradientY, dark_on_light, SWTImage, rays );
    SWTMedianFilter ( SWTImage, rays );

    IplImage * output2 =
            cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_32F, 1 );
    normalizeImage (SWTImage, output2);
    IplImage * saveSWT =
            cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_8U, 1 );
    cvConvertScale(output2, saveSWT, 255, 0);
    cvSaveImage ( "SWT.png", saveSWT);
    cvReleaseImage ( &output2 );
    cvReleaseImage( &saveSWT );

    // Calculate legally connect components from SWT and gradient image.
    // return type is a vector of vectors, where each outer vector is a component and
    // the inner vector contains the (y,x) of each pixel in that component.
    std::vector<std::vector<Point2d> > components = findLegallyConnectedComponents(SWTImage, rays);

    // Filter the components
    std::vector<std::vector<Point2d> > validComponents;
    std::vector<std::pair<Point2d,Point2d> > compBB;
    std::vector<Point2dFloat> compCenters;
    std::vector<float> compMedians;
    std::vector<Point2d> compDimensions;
    filterComponents(SWTImage, components, validComponents, compCenters, compMedians, compDimensions, compBB );

    IplImage * output3 =
            cvCreateImage ( cvGetSize ( input ), 8U, 3 );
    renderComponentsWithBoxes (SWTImage, validComponents, compBB, output3);
    cvSaveImage ( "components.png",output3);
    //cvReleaseImage ( &output3 );

    // Make chains of components
    std::vector<Chain> chains;
    chains = makeChains(input, validComponents, compCenters, compMedians, compDimensions, compBB);

    IplImage * output4 =
            cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_8U, 1 );
    renderChains ( SWTImage, validComponents, chains, output4 );
    //cvSaveImage ( "text.png", output4);

    IplImage * output5 =
            cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_8U, 3 );
    cvCvtColor (output4, output5, CV_GRAY2RGB);
    cvReleaseImage ( &output4 );

    /*IplImage * output =
            cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_8U, 3 );
    renderChainsWithBoxes ( SWTImage, validComponents, chains, compBB, output); */
    cvReleaseImage ( &gradientX );
    cvReleaseImage ( &gradientY );
    cvReleaseImage ( &SWTImage );
    cvReleaseImage ( &edgeImage );
    return output5;
}