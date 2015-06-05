#ifndef TEXT_DETECTION_H
#define TEXT_DETECTION_H

#include <opencv/cv.h>
#include "vector.h"

struct Point2d {
    int x;
    int y;
    float SWT;
};

struct Point2dFloat {
    float x;
    float y;
};

struct Ray {
    struct Point2d p;
    struct Point2d q;
    vector points;
};

struct Point3dFloat {
    float x;
    float y;
    float z;
};

struct Chain {
    int p;
    int q;
    float dist;
    bool merged;
    struct Point2dFloat direction;
    vector components;
};

// bool Point2dSort (Point2d const & lhs,
//                   Point2d const & rhs);

// IplImage * textDetection (IplImage *    float_input,
//                           bool dark_on_light);

// void strokeWidthTransform (IplImage * edgeImage,
//                            IplImage * gradientX,
//                            IplImage * gradientY,
//                            bool dark_on_light,
//                            IplImage * SWTImage,
//                            std::vector<Ray> & rays);

// void SWTMedianFilter (IplImage * SWTImage,
//                      std::vector<Ray> & rays);

// vector **
// findLegallyConnectedComponents (IplImage * SWTImage,
//                                 std::vector<Ray> & rays);

// vector **
// findLegallyConnectedComponentsRAY (IplImage * SWTImage,
//                                 std::vector<Ray> & rays);

// void componentStats(IplImage * SWTImage,
//                                         const std::vector<Point2d> & component,
//                                         float & mean, float & variance, float & median,
//                                         int & minx, int & miny, int & maxx, int & maxy);

// void filterComponents(IplImage * SWTImage,
//                       std::vector<std::vector<Point2d> > & components,
//                       std::vector<std::vector<Point2d> > & validComponents,
//                       std::vector<Point2dFloat> & compCenters,
//                       std::vector<float> & compMedians,
//                       std::vector<Point2d> & compDimensions,
//                       std::vector<std::pair<Point2d,Point2d> > & compBB );

// vector * makeChains( IplImage * colorImage,
//                  std::vector<std::vector<Point2d> > & components,
//                  std::vector<Point2dFloat> & compCenters,
//                  std::vector<float> & compMedians,
//                  std::vector<Point2d> & compDimensions,
//                  std::vector<std::pair<Point2d,Point2d> > & compBB);

#endif // TEXT_DETECTION_H

