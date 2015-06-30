//
//  DDPointList.h
//  MapMarker
//
//  Created by Siraj Raval on 5/15/15.
//  Copyright (c) 2015 Siraj Raval. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDPoint.h"

@interface DDPointList : NSObject

@property (readonly, nonatomic) NSArray *array;
@property (readonly, nonatomic) NSUInteger count;

+ (instancetype)sharedPointList;

- (void)addPoint:(DDPoint *)point;
- (void)deletePointAtIndex:(NSUInteger)index;
- (void)deleteAllPoints;

@end
