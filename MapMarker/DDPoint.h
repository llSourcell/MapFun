//
//  DDUoint.h
//  MapMarker
//
//  Created by Siraj Raval on 5/15/15.
//  Copyright (c) 2015 Siraj Raval. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCoreDataHelper.h"

@interface DDPoint : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;


@end