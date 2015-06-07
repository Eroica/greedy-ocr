#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/graph_traits.hpp>
#include <boost/graph/connected_components.hpp>
#include <boost/unordered_map.hpp>
#include <boost/graph/floyd_warshall_shortest.hpp>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/io.hpp>

#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <opencv/cxcore.h>

#include "component_analysis.h"
#include "text_detection.h"
#include "vector.h"


vector
findLegallyConnectedComponents(IplImage *SWTImage,
                               vector *rays)
{
    vector v;
    vector_init(&v);
    return v;

        // boost::unordered_map<int, int> map;
        // boost::unordered_map<int, Point2d> revmap;

        // typedef boost::adjacency_list<boost::vecS, boost::vecS, boost::undirectedS> Graph;
        // int num_vertices = 0;
        // // Number vertices for graph.  Associate each point with number
        // for( int row = 0; row < SWTImage->height; row++ ){
        //     float * ptr = (float*)(SWTImage->imageData + row * SWTImage->widthStep);
        //     for (int col = 0; col < SWTImage->width; col++ ){
        //         if (*ptr > 0) {
        //             map[row * SWTImage->width + col] = num_vertices;
        //             Point2d p;
        //             p.x = col;
        //             p.y = row;
        //             revmap[num_vertices] = p;
        //             num_vertices++;
        //         }
        //         ptr++;
        //     }
        // }

        // Graph g(num_vertices);

        // for( int row = 0; row < SWTImage->height; row++ ){
        //     float * ptr = (float*)(SWTImage->imageData + row * SWTImage->widthStep);
        //     for (int col = 0; col < SWTImage->width; col++ ){
        //         if (*ptr > 0) {
        //             // check pixel to the right, right-down, down, left-down
        //             int this_pixel = map[row * SWTImage->width + col];
        //             if (col+1 < SWTImage->width) {
        //                 float right = CV_IMAGE_ELEM(SWTImage, float, row, col+1);
        //                 if (right > 0 && ((*ptr)/right <= 3.0 || right/(*ptr) <= 3.0))
        //                     boost::add_edge(this_pixel, map.at(row * SWTImage->width + col + 1), g);
        //             }
        //             if (row+1 < SWTImage->height) {
        //                 if (col+1 < SWTImage->width) {
        //                     float right_down = CV_IMAGE_ELEM(SWTImage, float, row+1, col+1);
        //                     if (right_down > 0 && ((*ptr)/right_down <= 3.0 || right_down/(*ptr) <= 3.0))
        //                         boost::add_edge(this_pixel, map.at((row+1) * SWTImage->width + col + 1), g);
        //                 }
        //                 float down = CV_IMAGE_ELEM(SWTImage, float, row+1, col);
        //                 if (down > 0 && ((*ptr)/down <= 3.0 || down/(*ptr) <= 3.0))
        //                     boost::add_edge(this_pixel, map.at((row+1) * SWTImage->width + col), g);
        //                 if (col-1 >= 0) {
        //                     float left_down = CV_IMAGE_ELEM(SWTImage, float, row+1, col-1);
        //                     if (left_down > 0 && ((*ptr)/left_down <= 3.0 || left_down/(*ptr) <= 3.0))
        //                         boost::add_edge(this_pixel, map.at((row+1) * SWTImage->width + col - 1), g);
        //                 }
        //             }
        //         }
        //         ptr++;
        //     }
        // }

        // std::vector<int> c(num_vertices);

        // int num_comp = connected_components(g, &c[0]);

        // std::vector<std::vector<Point2d> > components;
        // components.reserve(num_comp);
        // std::cout << "Before filtering, " << num_comp << " components and " << num_vertices << " vertices" << std::endl;
        // for (int j = 0; j < num_comp; j++) {
        //     std::vector<Point2d> tmp;
        //     components.push_back( tmp );
        // }
        // for (int j = 0; j < num_vertices; j++) {
        //     Point2d p = revmap[j];
        //     (components[c[j]]).push_back(p);
        // }

        // return components;
}

vector
findLegallyConnectedComponentsRAY(IplImage *SWTImage,
                                  vector *rays)
{
    vector v;
    vector_init(&v);
    return v;


        // boost::unordered_map<int, int> map;
        // boost::unordered_map<int, Point2d> revmap;

        // typedef boost::adjacency_list<boost::vecS, boost::vecS, boost::undirectedS> Graph;
        // int num_vertices = 0;
        // // Number vertices for graph.  Associate each point with number
        // for( int row = 0; row < SWTImage->height; row++ ){
        //     float * ptr = (float*)(SWTImage->imageData + row * SWTImage->widthStep);
        //     for (int col = 0; col < SWTImage->width; col++ ){
        //         if (*ptr > 0) {
        //             map[row * SWTImage->width + col] = num_vertices;
        //             Point2d p;
        //             p.x = col;
        //             p.y = row;
        //             revmap[num_vertices] = p;
        //             num_vertices++;
        //         }
        //         ptr++;
        //     }
        // }

        // Graph g(num_vertices);

        // // Traverse and add edges to graph
        // for (std::vector<Ray>::const_iterator it = rays.begin(); it != rays.end(); it++) {
        //         float lastSW = 0;
        //         int lastRow = 0;
        //         int lastCol = 0;
        //         for (std::vector<Point2d>::const_iterator it2 = it->points.begin(); it2 != it->points.end(); it2++) {
        //                 float currentSW = CV_IMAGE_ELEM(SWTImage, float, it2->y, it2->x);
        //                 if (lastSW == 0) {}
        //                 else if (lastSW/currentSW<=3.0 || currentSW/lastSW<=3.0){
        //                         boost::add_edge(map.at(it2->y * SWTImage->width + it2->x), map.at(lastRow * SWTImage->width + lastCol), g);
        //                 }
        //                 lastSW = currentSW;
        //                 lastRow = it2->y;
        //                 lastCol = it2->x;
        //         }
        //         lastSW = 0;
        //         lastRow = 0;
        //         lastCol = 0;
        // }

        // std::vector<int> c(num_vertices);

        // int num_comp = connected_components(g, &c[0]);

        // std::vector<std::vector<Point2d> > components;
        // components.reserve(num_comp);
        // std::cout << "Before filtering, " << num_comp << " components and " << num_vertices << " vertices" << std::endl;
        // for (int j = 0; j < num_comp; j++) {
        //     std::vector<Point2d> tmp;
        //     components.push_back( tmp );
        // }
        // for (int j = 0; j < num_vertices; j++) {
        //     Point2d p = revmap[j];
        //     (components[c[j]]).push_back(p);
        // }

        // return components;
}