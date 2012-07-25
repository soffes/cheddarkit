//
//  CDKTag.h
//  CheddarKit
//
//  Created by Sam Soffes on 4/12/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "SSDataKit.h"

@class CDKTask;

@interface CDKTag : SSRemoteManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSSet *tasks;

+ (CDKTag *)existingTagWithName:(NSString *)name;
+ (CDKTag *)existingTagWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@end


@interface CDKTag (CoreDataGeneratedAccessors)
- (void)addTasksObject:(CDKTask *)value;
- (void)removeTasksObject:(CDKTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;
@end
