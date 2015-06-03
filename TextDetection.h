#ifndef TEXTDETECTION_H
#define TEXTDETECTION_H

#include "opencv/cv.h"
#include "points.h"

bool
Point2dSort(const Point2d *lhs,
            const Point2d *rhs);

IplImage *
textDetection(IplImage *float_input,
              bool dark_on_light);

void
strokeWidthTransform(IplImage *edgeImage,
                     IplImage *gradientX,
                     IplImage *gradientY,
                     bool dark_on_light,
                     IplImage *SWTImage,
                     NSMutableArray *rays);

void
SWTMedianFilter(IplImage *SWTImage,
                NSMutableArray *rays);

NSMutableArray *
findLegallyConnectedComponents(IplImage *SWTImage,
                               NSMutableArray *rays);

NSMutableArray *
findLegallyConnectedComponentsRAY(IplImage *SWTImage,
                                  NSMutableArray *rays);

void
componentStats(IplImage *SWTImage,
               const NSMutableArray *component,
               float *mean, float *variance, float *median,
               int *minx, int *miny, int *maxx, int *maxy);

void
filterComponents(IplImage *SWTImage,
                 NSMutableArray *components,
                 NSMutableArray *validComponents,
                 NSMutableArray *compCenters,
                 NSMutableArray *compMedians,
                 NSMutableArray *compDimensions,
                 NSMutableArray *compBB );

NSMutableArray *
makeChains(IplImage *colorImage,
           NSMutableArray *components,
           NSMutableArray *compCenters,
           NSMutableArray *compMedians,
           NSMutableArray *compDimensions,
           NSMutableArray *compBB);


#endif // TEXTDETECTION_H