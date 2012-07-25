//
//  CDKUser.h
//  CheddarKit
//
//  Created by Sam Soffes on 4/5/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "SSDataKit.h"

@class CDKList;
@class CDKTask;

extern NSString *const kCDKCurrentUserChangedNotificationName;

@interface CDKUser : SSRemoteManagedObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSNumber *hasPlus;
@property (nonatomic, strong) NSSet *tasks;
@property (nonatomic, strong) NSSet *lists;
@property (nonatomic, strong) NSString *accessToken;

+ (CDKUser *)currentUser;
+ (void)setCurrentUser:(CDKUser *)user;

@end


@interface CDKUser (CoreDataGeneratedAccessors)
- (void)addTasksObject:(CDKTask *)value;
- (void)removeTasksObject:(CDKTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

- (void)addListsObject:(CDKList *)value;
- (void)removeListsObject:(CDKList *)value;
- (void)addLists:(NSSet *)values;
- (void)removeLists:(NSSet *)values;
@end
