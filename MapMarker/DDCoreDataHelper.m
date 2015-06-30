//
//  DDCoreDataHelper.m
//  DDUtils
//
//  Created by Siraj Raval on 5/15/15.
//  Copyright (c) 2015 Siraj Raval. All rights reserved.
//

#import "DDCoreDataHelper.h"

@interface DDCoreDataHelper()

@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *coordinator;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation DDCoreDataHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        NSError *error = nil;
        
        // ManagedObjectModel
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:MODEL_FILE_NAME
                                                  withExtension:MODEL_FILE_EXT];
        _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        // PersistentStoreCoordinator
        NSURL *docsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
        NSURL *storeURL = [docsURL URLByAppendingPathComponent:STORE_FILE_NAME];
        _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:storeURL
                                              options:nil
                                                error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        // ManagedObjectContext
        _context = [[NSManagedObjectContext alloc] init];
        _context.persistentStoreCoordinator = _coordinator;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static id singleton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
}

- (void)save {
    NSError *error = nil;
    
    if ([self.context hasChanges] && ![self.context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (NSManagedObject *)addObjectForEntity:(NSString *)entityName {
    return [NSEntityDescription insertNewObjectForEntityForName:entityName
                                         inManagedObjectContext:self.context];
}

- (NSArray *)fetchObjectsForEntity:(NSString *)entityName {
    return [self fetchObjectsForEntity:entityName sortedBy:nil];
}

- (NSArray *)fetchObjectsForEntity:(NSString *)entityName sortedBy:(NSArray *)sortKeys {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
    if (sortKeys) {
        NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
        for (NSString *key in sortKeys) {
            NSSortDescriptor *sortDescr = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
            [sortDescriptors addObject:sortDescr];
        }
        request.sortDescriptors = sortDescriptors;
    }
    NSError *error = nil;
    NSArray *array = [self.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return array;
}

- (void)deleteObject:(NSManagedObject *)object {
    [self.context deleteObject:object];
}

@end


#pragma mark - NSManagedObject category

@implementation NSManagedObject(DDCoreDataHelper)

+ (NSString *)entityName { return @""; }

+ (instancetype)createObject {
    return (NSManagedObject *)[[DDCoreDataHelper sharedInstance] addObjectForEntity:[self entityName]];
}

@end;


