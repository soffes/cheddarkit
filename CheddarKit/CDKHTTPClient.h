//
//  CDKHTTPClient.h
//  CheddarKit
//
//  Created by Sam Soffes on 3/30/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "AFNetworking.h"

typedef void (^CDKHTTPClientSuccess)(AFJSONRequestOperation *operation, id responseObject);
typedef void (^CDKHTTPClientFailure)(AFJSONRequestOperation *operation, NSError *error);

@class CDKUser;
@class CDKList;
@class CDKTask;
@class BLYChannel;

@interface CDKHTTPClient : AFHTTPClient

+ (CDKHTTPClient *)sharedClient;
+ (void)setDevelopmentModeEnabled:(BOOL)enabled;
+ (NSString *)apiVersion;
- (void)setClientID:(NSString *)clientID secret:(NSString *)clientSecret;

- (void)changeUser:(CDKUser *)user;

// User
- (void)signInWithLogin:(NSString *)login password:(NSString *)password success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)signInWithAuthorizationCode:(NSString *)code success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)signUpWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)updateCurrentUserWithSuccess:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;

// Lists
- (void)getListsWithSuccess:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)createList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)updateList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)sortLists:(NSArray *)lists success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;

// Tasks
- (void)getTasksWithList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)createTask:(CDKTask *)task success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)updateTask:(CDKTask *)task success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)sortTasks:(NSArray *)tasks inList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)archiveAllTasksInList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;
- (void)archiveCompletedTasksInList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure;

@end