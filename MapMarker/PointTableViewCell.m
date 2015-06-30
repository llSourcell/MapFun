//
//  PointTableViewCell.m
//  MapMarker
//
//  Created by Siraj Raval on 5/15/15.
//  Copyright (c) 2015 Siraj Raval. All rights reserved.
//

#import "PointTableViewCell.h"

@interface PointTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end


@implementation PointTableViewCell

- (void)setupWithPoint:(DDPoint *)point {
    self.nameLabel.text = point.name;
    self.addressLabel.text = point.address;
}

@end
