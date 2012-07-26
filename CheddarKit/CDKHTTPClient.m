//
//  CDKTTPClient.m
//  CheddarKit
//
//  Created by Sam Soffes on 3/30/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "CDKHTTPClient.h"
#import "CDKList.h"
#import "CDKTask.h"
#import "CDKUser.h"
#import "CDKDefines.h"
#import <Bully/Bully.h>

static BOOL __developmentMode = NO;

@interface CDKHTTPClient ()
- (void)_userChanged:(NSNotification *)notification;
@end

@implementation CDKHTTPClient {
	dispatch_queue_t _callbackQueue;
	NSString *_clientID;
	NSString *_clientSecret;
}

#pragma mark - Singleton

+ (CDKHTTPClient *)sharedClient {
	static CDKHTTPClient *sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedClient = [[self alloc] init];
	});
	return sharedClient;
}


+ (void)setDevelopmentModeEnabled:(BOOL)enabled {
	__developmentMode = enabled;
}


+ (NSString *)apiVersion {
	return @"v1";
}


#pragma mark - NSObject

- (id)init {
	NSURL *base = nil;
	NSString *version = [[self class] apiVersion];
	if (__developmentMode) {
		base = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@/", kCDKDevelopmentAPIScheme, kCDKDevelopmentAPIHost, version]];
	} else {
		base = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@/", kCDKAPIScheme, kCDKAPIHost, version]];
	}
	
	if ((self = [super initWithBaseURL:base])) {
		// Use JSON
		[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
		[self setDefaultHeader:@"Accept" value:@"application/json"];
		
		if ([CDKUser currentUser]) {
			[self changeUser:[CDKUser currentUser]];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userChanged:) name:kCDKCurrentUserChangedNotificationName object:nil];
		_callbackQueue = dispatch_queue_create("com.nothingmagical.cheddar.network-callback-queue", 0);
	}
	return self;
}


- (void)dealloc {
	CDKDispatchRelease(_callbackQueue);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - AFHTTPClient

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	return request;
}


- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
	operation.successCallbackQueue = _callbackQueue;
	operation.failureCallbackQueue = _callbackQueue;
	[super enqueueHTTPRequestOperation:operation];
}


#pragma mark - Client

- (void)setClientID:(NSString *)clientID secret:(NSString *)clientSecret {
	_clientID = clientID;
	_clientSecret = clientSecret;
}


#pragma mark - User

- (void)signInWithLogin:(NSString *)login password:(NSString *)password success:(void (^)(AFJSONRequestOperation *operation, id responseObject))success failure:(void (^)(AFJSONRequestOperation *operation, NSError *error))failure {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							login, @"username",
							password, @"password",
							@"password", @"grant_type",
							nil];
	
	[self setAuthorizationHeaderWithUsername:_clientID password:_clientSecret];
	[self postPath:@"/oauth/token" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [CDKUser mainContext];
		[context performBlockAndWait:^{
			NSDictionary *dictionary = (NSDictionary *)responseObject;
			CDKUser *user = [CDKUser objectWithDictionary:[dictionary objectForKey:@"user"]];
			user.accessToken = [dictionary objectForKey:@"access_token"];
			[user save];
			
			[self changeUser:user];
			[CDKUser setCurrentUser:user];
		}];

		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
	[self clearAuthorizationHeader];
}


- (void)signInWithAuthorizationCode:(NSString *)code success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							code, @"code",
							@"authorization_code", @"grant_type",
							nil];
	
	[self setAuthorizationHeaderWithUsername:_clientID password:_clientSecret];
	[self postPath:@"/oauth/token" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [CDKUser mainContext];
		[context performBlockAndWait:^{
			NSDictionary *dictionary = (NSDictionary *)responseObject;
			CDKUser *user = [CDKUser objectWithDictionary:[dictionary objectForKey:@"user"]];
			user.accessToken = [dictionary objectForKey:@"access_token"];
			[user save];
			
			[self changeUser:user];
			[CDKUser setCurrentUser:user];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
	[self clearAuthorizationHeader];
}


- (void)signUpWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							username, @"user[username]",
							email, @"user[email]",
							password, @"user[password]",
							nil];
	
	[self setAuthorizationHeaderWithUsername:_clientID password:_clientSecret];
	[self postPath:@"users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [CDKUser mainContext];
		[context performBlockAndWait:^{
			NSDictionary *dictionary = (NSDictionary *)responseObject;
			CDKUser *user = [CDKUser objectWithDictionary:dictionary];
			user.accessToken = [[dictionary objectForKey:@"access_token"] objectForKey:@"access_token"];
			[self changeUser:user];
			[CDKUser setCurrentUser:user];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
	[self clearAuthorizationHeader];
}


- (void)updateCurrentUserWithSuccess:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	[self getPath:@"me" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [CDKUser mainContext];
		[context performBlockAndWait:^{
			CDKUser *currentUser = [CDKUser currentUser];
			[currentUser unpackDictionary:responseObject];
			[currentUser save];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


#pragma mark - Lists

- (void)getListsWithSuccess:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	[self getPath:@"lists" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [CDKList mainContext];
		[context performBlockAndWait:^{
			for (NSDictionary *dictionary in responseObject) {
				[CDKList objectWithDictionary:dictionary];
			}
			[context save:nil];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


- (void)createList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							list.title, @"list[title]",
							nil];
	
	__weak NSManagedObjectContext *context = [CDKList mainContext];
	[self postPath:@"lists" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[context performBlockAndWait:^{
			[list unpackDictionary:responseObject];
			[list save];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[context performBlockAndWait:^{
			[list delete];
		}];
		
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


- (void)updateList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@", list.remoteID];
	id archivedAt = list.archivedAt ? list.archivedAt : @"null";
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							list.title, @"list[title]",
							archivedAt, @"list[archived_at]",
							nil];
	
	[self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [CDKList mainContext];
		[context performBlockAndWait:^{
			[list unpackDictionary:responseObject];
			[list save];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


- (void)sortLists:(NSArray *)lists success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"lists/sort" parameters:nil];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	// Build the array of indexs
	NSMutableArray *components = [[NSMutableArray alloc] init];
	for (CDKList *list in lists) {
		[components addObject:[NSString stringWithFormat:@"list[]=%@", list.remoteID]];
	}
	request.HTTPBody = [[components componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
	
	AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
	[self enqueueHTTPRequestOperation:operation];
}


#pragma mark - Tasks

- (void)getTasksWithList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks?all=true", list.remoteID];
	[self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [CDKTask mainContext];
		[context performBlockAndWait:^{		
			for (NSDictionary *taskDictionary in responseObject) {
				CDKTask *task = [CDKTask objectWithDictionary:taskDictionary];
				task.list = list;
			}
			[context save:nil];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


- (void)createTask:(CDKTask *)task success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks", task.list.remoteID];
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							task.text, @"task[text]",
							nil];
	
	__weak NSManagedObjectContext *context = [CDKTask mainContext];
	[self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[context performBlockAndWait:^{
			[task unpackDictionary:responseObject];
			[task save];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[context performBlockAndWait:^{
			[task delete];
		}];
		
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


- (void)updateTask:(CDKTask *)task success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"tasks/%@", task.remoteID];
	id completedAt = task.completedAt ? task.completedAt : @"null";
	id archivedAt = task.archivedAt ? task.archivedAt : @"null";
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							task.text, @"task[text]",
							completedAt, @"task[completed_at]",
							archivedAt, @"task[archived_at]",
							nil];
	
	[self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [CDKTask mainContext];
		[context performBlockAndWait:^{
			[task unpackDictionary:responseObject];
			[task save];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


- (void)sortTasks:(NSArray *)tasks inList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks/sort", list.remoteID];
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:nil];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	// Build the array of indexs
	NSMutableArray *components = [[NSMutableArray alloc] init];
	for (CDKTask *task in tasks) {
		[components addObject:[NSString stringWithFormat:@"task[]=%@", task.remoteID]];
	}
	request.HTTPBody = [[components componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
	
	AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
	[self enqueueHTTPRequestOperation:operation];
}


- (void)archiveAllTasksInList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks/archive_all", list.remoteID];
	[self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


- (void)archiveCompletedTasksInList:(CDKList *)list success:(CDKHTTPClientSuccess)success failure:(CDKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks/archive_completed", list.remoteID];
	[self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


#pragma mark - Authentication

- (void)_userChanged:(NSNotification *)notification {
	[self changeUser:[CDKUser currentUser]];
}


- (void)changeUser:(CDKUser *)user {
	if (user.accessToken) {
		[self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", user.accessToken]];
		return;
	}
	
	[self clearAuthorizationHeader];
}

@end
