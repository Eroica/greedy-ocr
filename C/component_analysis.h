#ifndef COMPONENT_ANALYSIS_H
#define COMPONENT_ANALYSIS_H

#include "vector.h"

#ifdef __cplusplus
extern "C" {
#endif
vector
findLegallyConnectedComponents(IplImage *SWTImage,
                               vector *rays);
#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
extern "C" {
#endif
vector
findLegallyConnectedComponentsRAY(IplImage *SWTImage,
                                  vector *rays);
#ifdef __cplusplus
}
#endif

#endif // COMPONENT_ANALYSIS_H