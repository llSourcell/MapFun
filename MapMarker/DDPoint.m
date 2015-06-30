//
//  DDPoint.m
//  MapMarker
//
//  Created by Siraj Raval on 5/15/15.
//  Copyright (c) 2015 Siraj Raval. All rights reserved.
//

#import "DDPoint.h"

@implementation DDPoint

@dynamic name;
@dynamic address;
@dynamic latitude;
@dynamic longitude;

+ (NSString *)entityName { return @"Point"; }

@end
