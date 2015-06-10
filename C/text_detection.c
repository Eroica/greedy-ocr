/*
    Copyright 2012 Andrew Perrault and Saurav Kumar.

    This file is part of DetectText.

    DetectText is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    DetectText is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with DetectText.  If not, see <http://www.gnu.org/licenses/>.
*/
// #include <boost/graph/adjacency_list.hpp>
// #include <boost/graph/graph_traits.hpp>
// #include <boost/graph/connected_components.hpp>
// #include <boost/unordered_map.hpp>
// #include <boost/graph/floyd_warshall_shortest.hpp>
// #include <boost/numeric/ublas/matrix.hpp>
// #include <boost/numeric/ublas/io.hpp>
/*#include <graph/adjacency_list.hpp>
#include <graph/graph_traits.hpp>
#include <graph/connected_components.hpp>
#include <unordered_map.hpp>
#include <graph/floyd_warshall_shortest.hpp>
#include <numeric/ublas/matrix.hpp>
#include <numeric/ublas/io.hpp> */
// #include <cassert>
// #include <cmath>
// #include <iostream>
// #include <math.h>
// #include <time.h>
// #include <utility>
// #include <algorithm>
// #include <vector>
#include <stdio.h>
#include <math.h>
#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <opencv/cxcore.h>
#include "text_detection.h"
#include "component_analysis.h"
#include "vector.h"

#define PI 3.14159265

// std::vector<std::pair<CvPoint,CvPoint> > findBoundingBoxes( std::vector<std::vector<Point2d> > & components,
//                                                            std::vector<Chain> & chains,
//                                                            std::vector<std::pair<Point2d,Point2d> > & compBB,
//                                                            IplImage * output) {
//     std::vector<std::pair<CvPoint,CvPoint> > bb;
//     bb.reserve(chains.size());
//     for (std::vector<Chain>::iterator chainit = chains.begin(); chainit != chains.end(); chainit++) {
//         int minx = output->width;
//         int miny = output->height;
//         int maxx = 0;
//         int maxy = 0;
//         for (std::vector<int>::const_iterator cit = chainit->components.begin(); cit != chainit->components.end(); cit++) {
//                 miny = std::min(miny,compBB[*cit].first.y);
//                 minx = std::min(minx,compBB[*cit].first.x);
//                 maxy = std::max(maxy,compBB[*cit].second.y);
//                 maxx = std::max(maxx,compBB[*cit].second.x);
//         }
//         CvPoint p0 = cvPoint(minx,miny);
//         CvPoint p1 = cvPoint(maxx,maxy);
//         std::pair<CvPoint,CvPoint> pair(p0,p1);
//         bb.push_back(pair);
//     }
//     return bb;
// }

// std::vector<std::pair<CvPoint,CvPoint> > findBoundingBoxes( std::vector<std::vector<Point2d> > & components,
//                                                            IplImage * output) {
//     std::vector<std::pair<CvPoint,CvPoint> > bb;
//     bb.reserve(components.size());
//     for (std::vector<std::vector<Point2d> >::iterator compit = components.begin(); compit != components.end(); compit++) {
//         int minx = output->width;
//         int miny = output->height;
//         int maxx = 0;
//         int maxy = 0;
//         for (std::vector<Point2d>::iterator it = compit->begin(); it != compit->end(); it++) {
//                 miny = std::min(miny,it->y);
//                 minx = std::min(minx,it->x);
//                 maxy = std::max(maxy,it->y);
//                 maxx = std::max(maxx,it->x);
//         }
//         CvPoint p0 = cvPoint(minx,miny);
//         CvPoint p1 = cvPoint(maxx,maxy);
//         std::pair<CvPoint,CvPoint> pair(p0,p1);
//         bb.push_back(pair);
//     }
//     return bb;
// }

void
normalizeImage(IplImage *input,
               IplImage *output)
{
    assert(input->depth == IPL_DEPTH_32F);
    assert(input->nChannels == 1);
    assert(output->depth == IPL_DEPTH_32F);
    assert(output->nChannels == 1);

    float maxVal = 0;
    float minVal = 1e100;
    for(int row = 0; row < input->height; row++) {
        const float* ptr = (const float*)(input->imageData + row * input->widthStep);
        for(int col = 0; col < input->width; col++) {
            if(*ptr < 0) { }
            else {
                maxVal = fmax(*ptr, maxVal);
                minVal = fmin(*ptr, minVal);
            }
            ptr++;
        }
    }

    float difference = maxVal - minVal;
    for(int row = 0; row < input->height; row++) {
        const float* ptrin = (const float*)(input->imageData + row * input->widthStep);\
        float* ptrout = (float*)(output->imageData + row * output->widthStep);\
        for (int col = 0; col < input->width; col++) {
            if(*ptrin < 0) {
                *ptrout = 1;
            } else {
                *ptrout = ((*ptrin) - minVal)/difference;
            }
            ptrout++;
            ptrin++;
        }
    }
}

void
renderComponents(IplImage *SWTImage,
                vector *components,
                IplImage *output)
{
    cvZero(output);

    for(int it = 0; it < vector_get_size(components); it++) {
        for(int pit = 0; pit < vector_get_size(vector_get(components, it)); pit++) {
            CV_IMAGE_ELEM(output, float, ((struct Point2d *)vector_get(vector_get(components, it), pit))->y, ((struct Point2d *)vector_get(vector_get(components, it), pit))->x) = CV_IMAGE_ELEM(SWTImage, float, ((struct Point2d *)vector_get(vector_get(components, it), pit))->y, ((struct Point2d *)vector_get(vector_get(components, it), pit))->x);
        }
    }

    for(int row = 0; row < output->height; row++) {
        float *ptr = (float*)(output->imageData + row * output->widthStep);
        for(int col = 0; col < output->width; col++) {
            if(*ptr == 0) {
                *ptr = -1;
            }
            ptr++;
        }
    }

    float maxVal = 0;
    float minVal = 1e100;
    for(int row = 0; row < output->height; row++) {
        const float *ptr = (const float *)(output->imageData + row * output->widthStep);
        for(int col = 0; col < output->width; col++ ) {
            if(*ptr == 0) { }
            else {
                maxVal = fmax(*ptr, maxVal);
                minVal = fmin(*ptr, minVal);
            }
            ptr++;
        }
    }
    float difference = maxVal - minVal;
    for(int row = 0; row < output->height; row++) {
        float *ptr = (float*)(output->imageData + row * output->widthStep); \
        for(int col = 0; col < output->width; col++) {
            if (*ptr < 1) {
                *ptr = 1;
            } else {
                *ptr = ((*ptr) - minVal)/difference;
            }
            ptr++;
        }
    }
}

void
renderComponentsWithBoxes(IplImage *SWTImage,
                          vector components,
                          vector compBB,
                          IplImage *output)
{
    IplImage *outTemp = cvCreateImage(cvGetSize(output), IPL_DEPTH_32F, 1);

    renderComponents(SWTImage, &components, outTemp);
    // std::vector<std::pair<CvPoint,CvPoint> > bb;
    // bb.reserve(compBB.size());
    // for (std::vector<std::pair<Point2d,Point2d> >::iterator it=compBB.begin(); it != compBB.end(); it++ ) {
    //     CvPoint p0 = cvPoint(it->first.x,it->first.y);
    //     CvPoint p1 = cvPoint(it->second.x,it->second.y);
    //     std::pair<CvPoint,CvPoint> pair(p0,p1);
    //     bb.push_back(pair);
    // }

    // IplImage * out =
    //         cvCreateImage ( cvGetSize ( output ), IPL_DEPTH_8U, 1 );
    // cvConvertScale(outTemp, out, 255, 0);
    // cvCvtColor (out, output, CV_GRAY2RGB);
    // //cvReleaseImage ( &outTemp );
    // //cvReleaseImage ( &out );

    // int count = 0;
    // for (std::vector<std::pair<CvPoint,CvPoint> >::iterator it= bb.begin(); it != bb.end(); it++) {
    //     CvScalar c;
    //     if (count % 3 == 0) c=cvScalar(255,0,0);
    //     else if (count % 3 == 1) c=cvScalar(0,255,0);
    //     else c=cvScalar(0,0,255);
    //     count++;
    //     cvRectangle(output,it->first,it->second,c,2);
    // }
}

// void renderChainsWithBoxes (IplImage * SWTImage,
//                    std::vector<std::vector<Point2d> > & components,
//                    std::vector<Chain> & chains,
//                    std::vector<std::pair<Point2d,Point2d> > & compBB,
//                    IplImage * output) {
//     // keep track of included components
//     std::vector<bool> included;
//     included.reserve(components.size());
//     for (unsigned int i = 0; i != components.size(); i++) {
//         included.push_back(false);
//     }
//     for (std::vector<Chain>::iterator it = chains.begin(); it != chains.end();it++) {
//         for (std::vector<int>::iterator cit = it->components.begin(); cit != it->components.end(); cit++) {
//             included[*cit] = true;
//         }
//     }
//     std::vector<std::vector<Point2d> > componentsRed;
//     for (unsigned int i = 0; i != components.size(); i++ ) {
//         if (included[i]) {
//             componentsRed.push_back(components[i]);
//         }
//     }
//     IplImage * outTemp =
//             cvCreateImage ( cvGetSize ( output ), IPL_DEPTH_32F, 1 );

//     std::cout << componentsRed.size() << " components after chaining" << std::endl;
//     renderComponents(SWTImage,componentsRed,outTemp);
//     std::vector<std::pair<CvPoint,CvPoint> > bb;
//     bb = findBoundingBoxes(components, chains, compBB, outTemp);

//     IplImage * out =
//             cvCreateImage ( cvGetSize ( output ), IPL_DEPTH_8U, 1 );
//     cvConvertScale(outTemp, out, 255, 0);
//     cvCvtColor (out, output, CV_GRAY2RGB);
//     cvReleaseImage ( &out );
//     cvReleaseImage ( &outTemp);

//     int count = 0;
//     for (std::vector<std::pair<CvPoint,CvPoint> >::iterator it= bb.begin(); it != bb.end(); it++) {
//         CvScalar c;
//         if (count % 3 == 0) c=cvScalar(255,0,0);
//         else if (count % 3 == 1) c=cvScalar(0,255,0);
//         else c=cvScalar(0,0,255);
//         count++;
//         cvRectangle(output,it->first,it->second,c,2);
//     }
// }

// void renderChains (IplImage * SWTImage,
//                    std::vector<std::vector<Point2d> > & components,
//                    std::vector<Chain> & chains,
//                    IplImage * output) {
//     // keep track of included components
//     std::vector<bool> included;
//     included.reserve(components.size());
//     for (unsigned int i = 0; i != components.size(); i++) {
//         included.push_back(false);
//     }
//     for (std::vector<Chain>::iterator it = chains.begin(); it != chains.end();it++) {
//         for (std::vector<int>::iterator cit = it->components.begin(); cit != it->components.end(); cit++) {
//             included[*cit] = true;
//         }
//     }
//     std::vector<std::vector<Point2d> > componentsRed;
//     for (unsigned int i = 0; i != components.size(); i++ ) {
//         if (included[i]) {
//             componentsRed.push_back(components[i]);
//         }
//     }
//     std::cout << componentsRed.size() << " components after chaining" << std::endl;
//     IplImage * outTemp =
//             cvCreateImage ( cvGetSize ( output ), IPL_DEPTH_32F, 1 );
//     renderComponents(SWTImage,componentsRed,outTemp);
//     cvConvertScale(outTemp, output, 255, 0);
// 	cvReleaseImage(&outTemp);
// }

IplImage *
text_detection(IplImage *input_image, bool dark_on_light) {
    assert(input_image->depth == IPL_DEPTH_8U);
    assert(input_image->nChannels == 3);
    printf("Running text_detection with dark_on_light %i\n", dark_on_light);

    // Convert to grayscale
    IplImage *gray_image = cvCreateImage(cvGetSize(input_image), IPL_DEPTH_8U, 1);

    /* Convert to grayscale. */
    cvCvtColor(input_image, gray_image, CV_RGB2GRAY);

    /* Create Canny image. */
    double threshold_low = 175;
    double threshold_high = 320;
    IplImage *edge_image = cvCreateImage(cvGetSize(input_image), IPL_DEPTH_8U, 1);
    cvCanny(gray_image, edge_image, threshold_low, threshold_high, 3) ;
    cvSaveImage("canny.png", edge_image, 0);

    /* Create gradient X, gradient Y. */
    IplImage *gaussian_image = cvCreateImage(cvGetSize(input_image), IPL_DEPTH_32F, 1);
    cvConvertScale(gray_image, gaussian_image, 1./255., 0);
    // cvSmooth(gaussian_image, gaussian_image, CV_GAUSSIAN, 5, 5);
    cvSmooth(gaussian_image, gaussian_image, CV_GAUSSIAN, 5, 5, 0, 0);

    IplImage *gradientX = cvCreateImage(cvGetSize(input_image), IPL_DEPTH_32F, 1);
    IplImage *gradientY = cvCreateImage(cvGetSize(input_image), IPL_DEPTH_32F, 1);

    cvSobel(gaussian_image, gradientX, 1, 0, CV_SCHARR);
    cvSobel(gaussian_image, gradientY, 0, 1, CV_SCHARR);
    // cvSmooth(gradientX, gradientX, 3, 3);
    // cvSmooth(gradientY, gradientY, 3, 3);
    cvSmooth(gradientX, gradientX, 3, 3, 0, 0, 0);
    cvSmooth(gradientY, gradientY, 3, 3, 0, 0, 0);
    cvReleaseImage(&gaussian_image);
    cvReleaseImage(&gray_image);

    // Calculate SWT and return ray vectors
    vector rays;
    vector_init(&rays);

    IplImage *SWTImage = cvCreateImage (cvGetSize(input_image), IPL_DEPTH_32F, 1);
    for(int row = 0; row < input_image->height; row++) {
        float* ptr = (float*)(SWTImage->imageData + row * SWTImage->widthStep);
        for(int col = 0; col < input_image->width; col++) {
            *ptr++ = -1;
        }
    }

    strokeWidthTransform(edge_image, gradientX, gradientY, dark_on_light, SWTImage, &rays);
    SWTMedianFilter(SWTImage, &rays);

    IplImage *output2 = cvCreateImage(cvGetSize(input_image), IPL_DEPTH_32F, 1);
    normalizeImage(SWTImage, output2);
    IplImage *saveSWT = cvCreateImage(cvGetSize (input_image), IPL_DEPTH_8U, 1);
    cvConvertScale(output2, saveSWT, 255, 0);
    cvSaveImage("SWT.png", saveSWT, 0);
    cvReleaseImage(&output2);
    cvReleaseImage(&saveSWT);

    // Calculate legally connect components from SWT and gradient image.
    // return type is a vector of vectors, where each outer vector is a component and
    // the inner vector contains the (y,x) of each pixel in that component.
    vector components = findLegallyConnectedComponents(SWTImage, &rays);

    // Filter the components
    vector validComponents;
    vector compBB;
    vector compCenters;
    vector compMedians;
    vector compDimensions;
    vector_init(&validComponents);
    vector_init(&compBB);
    vector_init(&compCenters);
    vector_init(&compMedians);
    vector_init(&compDimensions);

    filterComponents(SWTImage, &components, &validComponents, &compCenters,
                     &compMedians, &compDimensions, &compBB);



    IplImage *output3 = cvCreateImage(cvGetSize(input_image), 8U, 3);
    renderComponentsWithBoxes(SWTImage, validComponents, compBB, output3);
    cvSaveImage("components.png", output3, 0);
    //cvReleaseImage ( &output3 );

//     // Make chains of components
//     std::vector<Chain> chains;
//     chains = makeChains(input, validComponents, compCenters, compMedians, compDimensions, compBB);

//     IplImage * output4 =
//             cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_8U, 1 );
//     renderChains ( SWTImage, validComponents, chains, output4 );
//     //cvSaveImage ( "text.png", output4);

//     IplImage * output5 =
//             cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_8U, 3 );
//     cvCvtColor (output4, output5, CV_GRAY2RGB);
//     cvReleaseImage ( &output4 );

//     /*IplImage * output =
//             cvCreateImage ( cvGetSize ( input ), IPL_DEPTH_8U, 3 );
//     renderChainsWithBoxes ( SWTImage, validComponents, chains, compBB, output); */
//     cvReleaseImage ( &gradientX );
//     cvReleaseImage ( &gradientY );
//     cvReleaseImage ( &SWTImage );
//     cvReleaseImage ( &edgeImage );
//     return output5;


    return SWTImage;
}

void
strokeWidthTransform(IplImage * edge_image,
                     IplImage * gradientX,
                     IplImage * gradientY,
                     bool dark_on_light,
                     IplImage * SWTImage,
                     vector *rays)
{
    // First pass
    float prec = .05;
    for(int row = 0; row < edge_image->height; row++) {
        const uchar* ptr = (const uchar*)(edge_image->imageData + row * edge_image->widthStep);
        for(int col = 0; col < edge_image->width; col++) {
            if (*ptr > 0) {
                struct Ray *r = calloc(1, sizeof(struct Ray));
                struct Point2d *p = calloc(1, sizeof(struct Point2d));
                p->x = col;
                p->y = row;
                r->p = *p;
                vector *points = calloc(1, sizeof(vector));
                vector_init(points);
                vector_push_back(points, p);

                float curX = (float)col + 0.5;
                float curY = (float)row + 0.5;
                int curPixX = col;
                int curPixY = row;
                float G_x = CV_IMAGE_ELEM ( gradientX, float, row, col);
                float G_y = CV_IMAGE_ELEM ( gradientY, float, row, col);
                // normalize gradient
                float mag = sqrt( (G_x * G_x) + (G_y * G_y) );
                if (dark_on_light){
                    G_x = -G_x/mag;
                    G_y = -G_y/mag;
                } else {
                    G_x = G_x/mag;
                    G_y = G_y/mag;

                }
                while(true) {
                    curX += G_x*prec;
                    curY += G_y*prec;
                    if ((int)(floor(curX)) != curPixX || (int)(floor(curY)) != curPixY) {
                        curPixX = (int)(floor(curX));
                        curPixY = (int)(floor(curY));
                        // check if pixel is outside boundary of image
                        if (curPixX < 0 || (curPixX >= SWTImage->width) || curPixY < 0 || (curPixY >= SWTImage->height)) {
                            break;
                        }
                        struct Point2d *pnew = calloc(1, sizeof(struct Point2d));
                        pnew->x = curPixX;
                        pnew->y = curPixY;
                        vector_push_back(points, pnew);

                        if (CV_IMAGE_ELEM ( edge_image, uchar, curPixY, curPixX) > 0) {
                            r->q = *pnew;
                            // dot product
                            float G_xt = CV_IMAGE_ELEM(gradientX,float,curPixY,curPixX);
                            float G_yt = CV_IMAGE_ELEM(gradientY,float,curPixY,curPixX);
                            mag = sqrt( (G_xt * G_xt) + (G_yt * G_yt) );
                            if (dark_on_light){
                                G_xt = -G_xt/mag;
                                G_yt = -G_yt/mag;
                            } else {
                                G_xt = G_xt/mag;
                                G_yt = G_yt/mag;

                            }

                            if (acos(G_x * -G_xt + G_y * -G_yt) < PI/2.0 ) {
                                float length = sqrt( ((float)r->q.x - (float)r->p.x)*((float)r->q.x - (float)r->p.x) + ((float)r->q.y - (float)r->p.y)*((float)r->q.y - (float)r->p.y));
                                for (int pit = 0; pit < vector_get_size(points); pit++) {
                                    if (CV_IMAGE_ELEM(SWTImage,
                                                      float,
                                                      ((struct Point2d *)vector_get(points, pit))->y,
                                                      ((struct Point2d *)vector_get(points, pit))->x) < 0) {
                                        CV_IMAGE_ELEM(SWTImage,
                                                      float,
                                                      ((struct Point2d *)vector_get(points, pit))->y,
                                                      ((struct Point2d *)vector_get(points, pit))->x) = length;
                                    } else {
                                        int minimum = fmin(length, CV_IMAGE_ELEM(SWTImage,
                                                                                 float,
                                                                                 ((struct Point2d *)vector_get(points, pit))->y,
                                                                                 ((struct Point2d *)vector_get(points, pit))->x));
                                        CV_IMAGE_ELEM(SWTImage,
                                                      float,
                                                      ((struct Point2d *)vector_get(points, pit))->y,
                                                      minimum);
                                    }
                                }
                                r->points = *points;
                                vector_push_back(rays, r);
                            }
                            break;
                        }
                    }
                }
            }
            ptr++;
        }
    }
}

void
SWTMedianFilter(IplImage *SWTImage,
                vector *rays)
{
    for(int rit = 0; rit < vector_get_size(rays); rit++) {
        struct Ray *ray = (struct Ray *)vector_get(rays, rit);
        vector *current_points;
        current_points = &ray->points;

        for(int pit = 0; pit < vector_get_size(&ray->points); pit++) {
            ((struct Point2d *)vector_get(&ray->points, pit))->SWT = CV_IMAGE_ELEM(SWTImage, float, ((struct Point2d *)vector_get(&ray->points, pit))->y, ((struct Point2d *)vector_get(&ray->points, pit))->x);
        }
        // std::sort(rit->points.begin(), rit->points.end(), &Point2dSort);

        struct Point2d *current_point = vector_get(current_points, vector_get_size(current_points)/2);
        float median = current_point->SWT;
        for (int pit = 0; pit < vector_get_size(&ray->points); pit++) {
            CV_IMAGE_ELEM(SWTImage, float, ((struct Point2d *)vector_get(&ray->points, pit))->y, ((struct Point2d *)vector_get(&ray->points, pit))->x) = fmin(((struct Point2d *)vector_get(&ray->points, pit))->SWT, median);
        }
    }
}

// bool Point2dSort (const Point2d &lhs, const Point2d &rhs) {
//     return lhs.SWT < rhs.SWT;
// }


void componentStats(IplImage *SWTImage,
                    vector *component,
                    float *mean, float *variance, float *median,
                    int *minx, int *miny, int *maxx, int *maxy)
{
    vector temp;
    vector_init(&temp);

    *mean = 0;
    *variance = 0;
    *minx = 1000000;
    *miny = 1000000;
    *maxx = 0;
    *maxy = 0;
    for(int it = 0; it < vector_get_size(component); it++) {
        float t = CV_IMAGE_ELEM(SWTImage,
                                float,
                                ((struct Point2d *)vector_get(component, it))->y,
                                ((struct Point2d *)vector_get(component, it))->x);
        *mean += t;
        vector_push_back(&temp, &t);
        *miny = fmin(*miny, ((struct Point2d *)vector_get(component, it))->y);
        *minx = fmin(*minx, ((struct Point2d *)vector_get(component, it))->x);
        *maxy = fmax(*maxy, ((struct Point2d *)vector_get(component, it))->y);
        *maxx = fmax(*maxx, ((struct Point2d *)vector_get(component, it))->x);
    }
    *mean = *mean / ((float)vector_get_size(component));

    for(int it = 0; it < vector_get_size(&temp); it++) {
        *variance = (*(float *)vector_get(&temp, it) - *mean) * (*(float *)vector_get(&temp, it) - *mean);
    }

    *variance = *variance / ((float)vector_get_size(component));
    // std::sort(temp.begin(),temp.end());
    *median = *(float *)vector_get(&temp, vector_get_size(&temp)/2);
}


void filterComponents(IplImage *SWTImage,
                      vector *components,
                      vector *validComponents,
                      vector *compCenters,
                      vector *compMedians,
                      vector *compDimensions,
                      vector *compBB)
{
    // validComponents.reserve(components.size());
    // compCenters.reserve(components.size());
    // compMedians.reserve(components.size());
    // compDimensions.reserve(components.size());
    // // bounding boxes
    // compBB.reserve(components.size());
    for(int it = 0; it < vector_get_size(components); it++) {
        // compute the stroke width mean, variance, median
        float mean, variance, median;
        int minx, miny, maxx, maxy;
        componentStats(SWTImage,
                      (vector *)vector_get(components, it),
                      &mean,
                      &variance,
                      &median,
                      &minx,
                      &miny,
                      &maxx,
                      &maxy);

        // check if variance is less than half the mean
        if (variance > 0.5 * mean) {
             continue;
        }

        float length = (float)(maxx-minx+1);
        float width = (float)(maxy-miny+1);

        // check font height
        if (width > 300) {
            continue;
        }

        float area = length * width;
        float rminx = (float)minx;
        float rmaxx = (float)maxx;
        float rminy = (float)miny;
        float rmaxy = (float)maxy;
        // compute the rotated bounding box
        float increment = 1./36.;

        for(float theta = increment * PI; theta < PI/2.0; theta += increment * PI) {
            float xmin, xmax, ymin, ymax, xtemp, ytemp, ltemp, wtemp;
            xmin = 1000000;
            ymin = 1000000;
            xmax = 0;
            ymax = 0;

            for(unsigned int i = 0; i < vector_get_size(vector_get(components, it)); i++) {
                xtemp = (*(struct Point2d *)vector_get(vector_get(components, it), i)).x * cos(theta) + (*(struct Point2d *)vector_get(vector_get(components, it), i)).y * -sin(theta);
                ytemp = (*(struct Point2d *)vector_get(vector_get(components, it), i)).x * sin(theta) + (*(struct Point2d *)vector_get(vector_get(components, it), i)).y *  cos(theta);
                xmin = fmin(xtemp, xmin);
                xmax = fmax(xtemp, xmax);
                ymin = fmin(ytemp, ymin);
                ymax = fmax(ytemp, ymax);
            }
            ltemp = xmax - xmin + 1;
            wtemp = ymax - ymin + 1;
            if (ltemp*wtemp < area) {
                area = ltemp*wtemp;
                length = ltemp;
                width = wtemp;
            }
        }
        // check if the aspect ratio is between 1/10 and 10
        if (length/width < 1./10. || length/width > 10.) {
            continue;
        }

        // compute the diameter TODO finish
        // compute dense representation of component
        vector denseRepr;
        vector_init(&denseRepr);

        for(int i = 0; i < maxx - minx + 1; i++) {
            vector tmp;
            vector_init(&tmp);
            vector_push_back(&denseRepr, &tmp);

            for (int j = 0; j < maxy - miny + 1; j++) {
                vector_push_back(vector_get(&denseRepr, i), 0);
            }
        }

        for (int pit = 0; pit < vector_get_size(vector_get(vector_get(components, it), pit)); pit++) {
            vector_get(
                vector_get(&denseRepr, ((struct Point2d *)vector_get(vector_get(components, it), pit))->x - minx),
                ((struct Point2d *)vector_get(vector_get(components, it), pit))->y - miny) \
                = 1;
        }
        create graph representing components
        const int num_nodes = vector_get_size(vector_get(components, it));

        /*
        E edges[] = { E(0,2),
                      E(1,1), E(1,3), E(1,4),
                      E(2,1), E(2,3),
                      E(3,4),
                      E(4,0), E(4,1) };

        Graph G(edges + sizeof(edges) / sizeof(E), weights, num_nodes);
        */

        struct Point2dFloat center;
        center.x = ((float)(maxx+minx))/2.0;
        center.y = ((float)(maxy+miny))/2.0;

        struct Point2d dimensions;
        dimensions.x = maxx - minx + 1;
        dimensions.y = maxy - miny + 1;

        struct Point2d bb1;
        bb1.x = minx;
        bb1.y = miny;

        struct Point2d bb2;
        bb2.x = maxx;
        bb2.y = maxy;
        std::pair<Point2d, Point2d> pair(bb1,bb2);

        compBB.push_back(pair);
        compDimensions.push_back(dimensions);
        compMedians.push_back(median);
        compCenters.push_back(center);
        validComponents.push_back(*it);
    }

    std::vector<std::vector<Point2d > > tempComp;
    std::vector<Point2d > tempDim;
    std::vector<float > tempMed;
    std::vector<Point2dFloat > tempCenters;
    std::vector<std::pair<Point2d,Point2d> > tempBB;
    tempComp.reserve(validComponents.size());
    tempCenters.reserve(validComponents.size());
    tempDim.reserve(validComponents.size());
    tempMed.reserve(validComponents.size());
    tempBB.reserve(validComponents.size());

    for (unsigned int i = 0; i < validComponents.size(); i++) {
        int count = 0;
        for (unsigned int j = 0; j < validComponents.size(); j++) {
            if (i != j) {
                if (compBB[i].first.x <= compCenters[j].x && compBB[i].second.x >= compCenters[j].x &&
                    compBB[i].first.y <= compCenters[j].y && compBB[i].second.y >= compCenters[j].y) {
                    count++;
                }
            }
        }
        if (count < 2) {
            tempComp.push_back(validComponents[i]);
            tempCenters.push_back(compCenters[i]);
            tempMed.push_back(compMedians[i]);
            tempDim.push_back(compDimensions[i]);
            tempBB.push_back(compBB[i]);
        }
    }
    validComponents = tempComp;
    compDimensions = tempDim;
    compMedians = tempMed;
    compCenters = tempCenters;
    compBB = tempBB;

    compDimensions.reserve(tempComp.size());
    compMedians.reserve(tempComp.size());
    compCenters.reserve(tempComp.size());
    validComponents.reserve(tempComp.size());
    compBB.reserve(tempComp.size());

    std::cout << "After filtering " << validComponents.size() << " components" << std::endl;
}



// bool sharesOneEnd( Chain c0, Chain c1) {
//     if (c0.p == c1.p || c0.p == c1.q || c0.q == c1.q || c0.q == c1.p) {
//         return true;
//     }
//     else {
//         return false;
//     }
// }

// bool chainSortDist (const Chain &lhs, const Chain &rhs) {
//     return lhs.dist < rhs.dist;
// }

// bool chainSortLength (const Chain &lhs, const Chain &rhs) {
//     return lhs.components.size() > rhs.components.size();
// }

// std::vector<Chain> makeChains( IplImage * colorImage,
//                  std::vector<std::vector<Point2d> > & components,
//                  std::vector<Point2dFloat> & compCenters,
//                  std::vector<float> & compMedians,
//                  std::vector<Point2d> & compDimensions,
//                  std::vector<std::pair<Point2d,Point2d> > & compBB) {
//     assert (compCenters.size() == components.size());
//     // make vector of color averages
//     std::vector<Point3dFloat> colorAverages;
//     colorAverages.reserve(components.size());
//     for (std::vector<std::vector<Point2d> >::iterator it = components.begin(); it != components.end();it++) {
//         Point3dFloat mean;
//         mean.x = 0;
//         mean.y = 0;
//         mean.z = 0;
//         int num_points = 0;
//         for (std::vector<Point2d>::iterator pit = it->begin(); pit != it->end(); pit++) {
//             mean.x += (float) CV_IMAGE_ELEM (colorImage, unsigned char, pit->y, (pit->x)*3 );
//             mean.y += (float) CV_IMAGE_ELEM (colorImage, unsigned char, pit->y, (pit->x)*3+1 );
//             mean.z += (float) CV_IMAGE_ELEM (colorImage, unsigned char, pit->y, (pit->x)*3+2 );
//             num_points++;
//         }
//         mean.x = mean.x / ((float)num_points);
//         mean.y = mean.y / ((float)num_points);
//         mean.z = mean.z / ((float)num_points);
//         colorAverages.push_back(mean);
//     }

//     // form all eligible pairs and calculate the direction of each
//     std::vector<Chain> chains;
//     for ( unsigned int i = 0; i < components.size(); i++ ) {
//         for ( unsigned int j = i + 1; j < components.size(); j++ ) {
//             // TODO add color metric
//             if ( (compMedians[i]/compMedians[j] <= 2.0 || compMedians[j]/compMedians[i] <= 2.0) &&
//                  (compDimensions[i].y/compDimensions[j].y <= 2.0 || compDimensions[j].y/compDimensions[i].y <= 2.0)) {
//                 float dist = (compCenters[i].x - compCenters[j].x) * (compCenters[i].x - compCenters[j].x) +
//                              (compCenters[i].y - compCenters[j].y) * (compCenters[i].y - compCenters[j].y);
//                 float colorDist = (colorAverages[i].x - colorAverages[j].x) * (colorAverages[i].x - colorAverages[j].x) +
//                                   (colorAverages[i].y - colorAverages[j].y) * (colorAverages[i].y - colorAverages[j].y) +
//                                   (colorAverages[i].z - colorAverages[j].z) * (colorAverages[i].z - colorAverages[j].z);
//                 if (dist < 9*(float)(std::max(std::min(compDimensions[i].x,compDimensions[i].y),std::min(compDimensions[j].x,compDimensions[j].y)))
//                     *(float)(std::max(std::min(compDimensions[i].x,compDimensions[i].y),std::min(compDimensions[j].x,compDimensions[j].y)))
//                     && colorDist < 1600) {
//                     Chain c;
//                     c.p = i;
//                     c.q = j;
//                     std::vector<int> comps;
//                     comps.push_back(c.p);
//                     comps.push_back(c.q);
//                     c.components = comps;
//                     c.dist = dist;
//                     float d_x = (compCenters[i].x - compCenters[j].x);
//                     float d_y = (compCenters[i].y - compCenters[j].y);
//                     /*
//                     float d_x = (compBB[i].first.x - compBB[j].second.x);
//                     float d_y = (compBB[i].second.y - compBB[j].second.y);
//                     */
//                     float mag = sqrt(d_x*d_x + d_y*d_y);
//                     d_x = d_x / mag;
//                     d_y = d_y / mag;
//                     Point2dFloat dir;
//                     dir.x = d_x;
//                     dir.y = d_y;
//                     c.direction = dir;
//                     chains.push_back(c);

//                     /*std::cerr << c.p << " " << c.q << std::endl;
//                     std::cerr << c.direction.x << " " << c.direction.y << std::endl;
//                     std::cerr << compCenters[c.p].x << " " << compCenters[c.p].y << std::endl;
//                     std::cerr << compCenters[c.q].x << " " << compCenters[c.q].y << std::endl;
//                     std::cerr << std::endl;
//                     std::cerr << colorDist << std::endl; */
//                 }
//             }
//         }
//     }
//     std::cout << chains.size() << " eligible pairs" << std::endl;
//     std::sort(chains.begin(), chains.end(), &chainSortDist);

//     std::cerr << std::endl;
//     const float strictness = PI/6.0;
//     //merge chains
//     int merges = 1;
//     while (merges > 0) {
//         for (unsigned int i = 0; i < chains.size(); i++) {
//             chains[i].merged = false;
//         }
//         merges = 0;
//         std::vector<Chain> newchains;
//         for (unsigned int i = 0; i < chains.size(); i++) {
//             for (unsigned int j = 0; j < chains.size(); j++) {
//                 if (i != j) {
//                     if (!chains[i].merged && !chains[j].merged && sharesOneEnd(chains[i],chains[j])) {
//                         if (chains[i].p == chains[j].p) {
//                             if (acos(chains[i].direction.x * -chains[j].direction.x + chains[i].direction.y * -chains[j].direction.y) < strictness) {
//                                   /*      if (chains[i].p == chains[i].q || chains[j].p == chains[j].q) {
//                                             std::cout << "CRAZY ERROR" << std::endl;
//                                         } else if (chains[i].p == chains[j].p && chains[i].q == chains[j].q) {
//                                             std::cout << "CRAZY ERROR" << std::endl;
//                                         } else if (chains[i].p == chains[j].q && chains[i].q == chains[j].p) {
//                                             std::cout << "CRAZY ERROR" << std::endl;
//                                         }
//                                         std::cerr << 1 <<std::endl;

//                                         std::cerr << chains[i].p << " " << chains[i].q << std::endl;
//                                         std::cerr << chains[j].p << " " << chains[j].q << std::endl;
//                                 std::cerr << compCenters[chains[i].q].x << " " << compCenters[chains[i].q].y << std::endl;
//                                 std::cerr << compCenters[chains[i].p].x << " " << compCenters[chains[i].p].y << std::endl;
//                                 std::cerr << compCenters[chains[j].q].x << " " << compCenters[chains[j].q].y << std::endl;
//                                 std::cerr << std::endl; */

//                                 chains[i].p = chains[j].q;
//                                 for (std::vector<int>::iterator it = chains[j].components.begin(); it != chains[j].components.end(); it++) {
//                                     chains[i].components.push_back(*it);
//                                 }
//                                 float d_x = (compCenters[chains[i].p].x - compCenters[chains[i].q].x);
//                                 float d_y = (compCenters[chains[i].p].y - compCenters[chains[i].q].y);
//                                 chains[i].dist = d_x * d_x + d_y * d_y;

//                                 float mag = sqrt(d_x*d_x + d_y*d_y);
//                                 d_x = d_x / mag;
//                                 d_y = d_y / mag;
//                                 Point2dFloat dir;
//                                 dir.x = d_x;
//                                 dir.y = d_y;
//                                 chains[i].direction = dir;
//                                 chains[j].merged = true;
//                                 merges++;
//                                 /*j=-1;
//                                 i=0;
//                                 if (i == chains.size() - 1) i=-1;
//                                 std::stable_sort(chains.begin(), chains.end(), &chainSortLength);*/
//                             }
//                         } else if (chains[i].p == chains[j].q) {
//                             if (acos(chains[i].direction.x * chains[j].direction.x + chains[i].direction.y * chains[j].direction.y) < strictness) {
// /*
//                                 if (chains[i].p == chains[i].q || chains[j].p == chains[j].q) {
//                                     std::cout << "CRAZY ERROR" << std::endl;
//                                 } else if (chains[i].p == chains[j].p && chains[i].q == chains[j].q) {
//                                     std::cout << "CRAZY ERROR" << std::endl;
//                                 } else if (chains[i].p == chains[j].q && chains[i].q == chains[j].p) {
//                                     std::cout << "CRAZY ERROR" << std::endl;
//                                 }
//                                 std::cerr << 2 <<std::endl;

//                                 std::cerr << chains[i].p << " " << chains[i].q << std::endl;
//                                 std::cerr << chains[j].p << " " << chains[j].q << std::endl;
//                                 std::cerr << chains[i].direction.x << " " << chains[i].direction.y << std::endl;
//                                 std::cerr << chains[j].direction.x << " " << chains[j].direction.y << std::endl;
//                                 std::cerr << compCenters[chains[i].q].x << " " << compCenters[chains[i].q].y << std::endl;
//                                 std::cerr << compCenters[chains[i].p].x << " " << compCenters[chains[i].p].y << std::endl;
//                                 std::cerr << compCenters[chains[j].p].x << " " << compCenters[chains[j].p].y << std::endl;
//                                 std::cerr << std::endl; */

//                                 chains[i].p = chains[j].p;
//                                 for (std::vector<int>::iterator it = chains[j].components.begin(); it != chains[j].components.end(); it++) {
//                                     chains[i].components.push_back(*it);
//                                 }
//                                 float d_x = (compCenters[chains[i].p].x - compCenters[chains[i].q].x);
//                                 float d_y = (compCenters[chains[i].p].y - compCenters[chains[i].q].y);
//                                 float mag = sqrt(d_x*d_x + d_y*d_y);
//                                 chains[i].dist = d_x * d_x + d_y * d_y;

//                                 d_x = d_x / mag;
//                                 d_y = d_y / mag;

//                                 Point2dFloat dir;
//                                 dir.x = d_x;
//                                 dir.y = d_y;
//                                 chains[i].direction = dir;
//                                 chains[j].merged = true;
//                                 merges++;
//                                 /*j=-1;
//                                 i=0;
//                                 if (i == chains.size() - 1) i=-1;
//                                 std::stable_sort(chains.begin(), chains.end(), &chainSortLength); */
//                             }
//                         } else if (chains[i].q == chains[j].p) {
//                             if (acos(chains[i].direction.x * chains[j].direction.x + chains[i].direction.y * chains[j].direction.y) < strictness) {
//      /*                           if (chains[i].p == chains[i].q || chains[j].p == chains[j].q) {
//                                     std::cout << "CRAZY ERROR" << std::endl;
//                                 } else if (chains[i].p == chains[j].p && chains[i].q == chains[j].q) {
//                                     std::cout << "CRAZY ERROR" << std::endl;
//                                 } else if (chains[i].p == chains[j].q && chains[i].q == chains[j].p) {
//                                     std::cout << "CRAZY ERROR" << std::endl;
//                                 }
//                                 std::cerr << 3 <<std::endl;

//                                 std::cerr << chains[i].p << " " << chains[i].q << std::endl;
//                                 std::cerr << chains[j].p << " " << chains[j].q << std::endl;

//                                 std::cerr << compCenters[chains[i].p].x << " " << compCenters[chains[i].p].y << std::endl;
//                                 std::cerr << compCenters[chains[i].q].x << " " << compCenters[chains[i].q].y << std::endl;
//                                 std::cerr << compCenters[chains[j].q].x << " " << compCenters[chains[j].q].y << std::endl;
//                                 std::cerr << std::endl; */
//                                 chains[i].q = chains[j].q;
//                                 for (std::vector<int>::iterator it = chains[j].components.begin(); it != chains[j].components.end(); it++) {
//                                     chains[i].components.push_back(*it);
//                                 }
//                                 float d_x = (compCenters[chains[i].p].x - compCenters[chains[i].q].x);
//                                 float d_y = (compCenters[chains[i].p].y - compCenters[chains[i].q].y);
//                                 float mag = sqrt(d_x*d_x + d_y*d_y);
//                                 chains[i].dist = d_x * d_x + d_y * d_y;


//                                 d_x = d_x / mag;
//                                 d_y = d_y / mag;
//                                 Point2dFloat dir;
//                                 dir.x = d_x;
//                                 dir.y = d_y;

//                                 chains[i].direction = dir;
//                                 chains[j].merged = true;
//                                 merges++;
//                                 /*j=-1;
//                                 i=0;
//                                 if (i == chains.size() - 1) i=-1;
//                                 std::stable_sort(chains.begin(), chains.end(), &chainSortLength); */
//                             }
//                         } else if (chains[i].q == chains[j].q) {
//                             if (acos(chains[i].direction.x * -chains[j].direction.x + chains[i].direction.y * -chains[j].direction.y) < strictness) {
//                      /*           if (chains[i].p == chains[i].q || chains[j].p == chains[j].q) {
//                                     std::cout << "CRAZY ERROR" << std::endl;
//                                 } else if (chains[i].p == chains[j].p && chains[i].q == chains[j].q) {
//                                     std::cout << "CRAZY ERROR" << std::endl;
//                                 } else if (chains[i].p == chains[j].q && chains[i].q == chains[j].p) {
//                                     std::cout << "CRAZY ERROR" << std::endl;
//                                 }
//                                 std::cerr << 4 <<std::endl;
//                                 std::cerr << chains[i].p << " " << chains[i].q << std::endl;
//                                 std::cerr << chains[j].p << " " << chains[j].q << std::endl;
//                                 std::cerr << compCenters[chains[i].p].x << " " << compCenters[chains[i].p].y << std::endl;
//                                 std::cerr << compCenters[chains[i].q].x << " " << compCenters[chains[i].q].y << std::endl;
//                                 std::cerr << compCenters[chains[j].p].x << " " << compCenters[chains[j].p].y << std::endl;
//                                 std::cerr << std::endl; */
//                                 chains[i].q = chains[j].p;
//                                 for (std::vector<int>::iterator it = chains[j].components.begin(); it != chains[j].components.end(); it++) {
//                                     chains[i].components.push_back(*it);
//                                 }
//                                 float d_x = (compCenters[chains[i].p].x - compCenters[chains[i].q].x);
//                                 float d_y = (compCenters[chains[i].p].y - compCenters[chains[i].q].y);
//                                 chains[i].dist = d_x * d_x + d_y * d_y;

//                                 float mag = sqrt(d_x*d_x + d_y*d_y);
//                                 d_x = d_x / mag;
//                                 d_y = d_y / mag;
//                                 Point2dFloat dir;
//                                 dir.x = d_x;
//                                 dir.y = d_y;
//                                 chains[i].direction = dir;
//                                 chains[j].merged = true;
//                                 merges++;
//                                 /*j=-1;
//                                 i=0;
//                                 if (i == chains.size() - 1) i=-1;
//                                 std::stable_sort(chains.begin(), chains.end(), &chainSortLength);*/
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//         for (unsigned int i = 0; i < chains.size(); i++) {
//             if (!chains[i].merged) {
//                 newchains.push_back(chains[i]);
//             }
//         }
//         chains = newchains;
//         std::stable_sort(chains.begin(), chains.end(), &chainSortLength);
//     }

//     std::vector<Chain> newchains;
//     newchains.reserve(chains.size());
//     for (std::vector<Chain>::iterator cit = chains.begin(); cit != chains.end(); cit++) {
//         if (cit->components.size() >= 3) {
//             newchains.push_back(*cit);
//         }
//     }
//     chains = newchains;
//     std::cout << chains.size() << " chains after merging" << std::endl;
//     return chains;
// }