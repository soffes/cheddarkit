//
//  CDKList.h
//  CheddarKit
//
//  Created by Sam Soffes on 4/5/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "CDKRemoteManagedObject.h"

@class CDKTask;

@interface CDKList : CDKRemoteManagedObject

@property (nonatomic, strong) NSDate *archivedAt;
@property (nonatomic, strong) NSNumber *position;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSSet *tasks;
@property (nonatomic, strong) NSManagedObject *user;

- (NSInteger)highestPosition;
- (NSArray *)sortedTasks;
- (NSArray *)sortedActiveTasks;
- (NSArray *)sortedCompletedActiveTasks;

- (void)archiveAllTasks;
- (void)archiveCompletedTasks;

@end


@interface CDKList (CoreDataGeneratedAccessors)
- (void)addTasksObject:(CDKTask *)value;
- (void)removeTasksObject:(CDKTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;
@end
