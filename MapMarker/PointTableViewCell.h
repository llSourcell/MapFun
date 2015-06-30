//
//  PointTableViewCell.h
//  MapMarker
//
//  Created by Siraj Raval on 5/15/15.
//  Copyright (c) 2015 Siraj Raval. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPoint.h"

@interface PointTableViewCell : UITableViewCell

- (void)setupWithPoint:(DDPoint *)point;

@end
