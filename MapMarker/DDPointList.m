//
//  DDPointList.m
//  MapMarker
//
//  Created by Siraj Raval on 5/15/15.
//  Copyright (c) 2015 Siraj Raval. All rights reserved.
//

#import "DDPointList.h"

@interface DDPointList()

@property (strong, nonatomic) NSMutableArray *pointList;
@property (weak, nonatomic) DDCoreDataHelper *coreData;

@end

@implementation DDPointList


- (instancetype)init {
    self = [super init];
    if (self) {
        self.coreData = [DDCoreDataHelper sharedInstance];
        self.pointList = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)sharedPointList {
    
    static DDPointList *singleton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
        [singleton loadPoints];
    });
    
    return singleton;
}

- (NSArray *)array {
    return self.pointList;
}

- (NSUInteger)count {
    return self.array.count;
}

- (void)loadPoints {
    [self.pointList removeAllObjects];
    [self.pointList addObjectsFromArray:[self.coreData fetchObjectsForEntity:[DDPoint entityName]]];
}

- (void)addPoint:(DDPoint *)point {
    [self.pointList addObject:point];
    [self.coreData save];
}

- (void)deletePointAtIndex:(NSUInteger)index {
    [self.coreData deleteObject:self.array[index]];
    [self.pointList removeObjectAtIndex:index];
    [self.coreData save];
}

- (void)deleteAllPoints {
    for (DDPoint *point in self.pointList) {
        [self.coreData deleteObject:point];
    }
    [self.pointList removeAllObjects];
    [self.coreData save];
}

@end
