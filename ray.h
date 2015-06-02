#import <Foundation/Foundation.h>
#include "TextDetection.h"

// Others.
@interface Ray : NSObject {

}

@property (nonatomic, assign) Point2d p;
@property (nonatomic, assign) Point2d q;
@property (nonatomic, assign) NSMutableArray *points;

@end