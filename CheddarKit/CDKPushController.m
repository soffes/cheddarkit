//
//  CDKPushController.m
//  CheddarKit
//
//  Created by Sam Soffes on 4/9/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "CDKPushController.h"
#import "CDKList.h"
#import "CDKTask.h"
#import "CDKHTTPClient.h"
#import "CDKUser.h"
#import "CDKDefines.h"
#import <Bully/Bully.h>
#import "Reachability.h"

static BOOL __developmentMode = NO;

@interface CDKPushController () <BLYClientDelegate>
@property (nonatomic, strong, readwrite) BLYClient *client;
@property (nonatomic, strong, readwrite) BLYChannel *userChannel;
@property (nonatomic, strong) NSString *userID;
- (void)_userChanged:(NSNotification *)notification;
- (void)_appDidEnterBackground:(NSNotification *)notificaiton;
- (void)_appDidBecomeActive:(NSNotification *)notification;
- (void)_reachabilityChanged:(NSNotification *)notification;
@end

@implementation CDKPushController {
	Reachability *_reachability;
}

@synthesize client = _client;
@synthesize userChannel = _userChannel;
@synthesize userID = _userID;

- (void)setUserID:(NSString *)userID {
	[self.userChannel unsubscribe];
	self.userChannel = nil;
	
	_userID = userID;
	
	if (!_userID) {
		return;
	}
	
	// Subscribe to user channel
	NSString *channelName = [NSString stringWithFormat:@"private-user-%@", _userID];
	self.userChannel = [self.client subscribeToChannelWithName:channelName authenticationBlock:^(BLYChannel *channel) {
		[[CDKHTTPClient sharedClient] postPath:@"/pusher/auth" parameters:channel.authenticationParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
			[channel subscribeWithAuthentication:responseObject];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Failed to authorize Pusher channel: %@", error);
		}];
	}];
	
	// Bind to list create
	[self.userChannel bindToEvent:@"list-create" block:^(id message) {
		CDKList *list = [CDKList objectWithDictionary:message];
		[list.managedObjectContext save:nil];
	}];
	
	// Bind to list update
	[self.userChannel bindToEvent:@"list-update" block:^(id message) {
		CDKList *list = [CDKList objectWithDictionary:message];
		[list save];

		[[NSNotificationCenter defaultCenter] postNotificationName:kCDKListDidUpdateNotificationName object:list.remoteID];
	}];
	
	// Bind to list reorder
	[self.userChannel bindToEvent:@"list-reorder" block:^(id message) {
		for (NSDictionary *dictionary in [message objectForKey:@"lists"]) {
			CDKList *list = [CDKList existingObjectWithRemoteID:[dictionary objectForKey:@"id"]];
			list.position = [dictionary objectForKey:@"position"];
		}
		[[CDKList mainContext] save:nil];
	}];

	// Bind to task create
	[self.userChannel bindToEvent:@"task-create" block:^(id message) {
		CDKList *list = [CDKList existingObjectWithRemoteID:[message objectForKey:@"list_id"]];
		if (!list) {
			return;
		}

		CDKTask *task = [CDKTask objectWithDictionary:message];
		task.list = list;
		[task save];
	}];
	
	// Bind to task update
	[self.userChannel bindToEvent:@"task-update" block:^(id message) {
		CDKList *list = [CDKList existingObjectWithRemoteID:[message objectForKey:@"list_id"]];
		if (!list) {
			return;
		}

		CDKTask *task = [CDKTask objectWithDictionary:message];
		task.list = list;
		[task save];
	}];
	
	// Bind to task reorder
	[self.userChannel bindToEvent:@"task-reorder" block:^(id message) {
		for (NSDictionary *dictionary in [message objectForKey:@"tasks"]) {
			CDKTask *task = [CDKTask existingObjectWithRemoteID:[dictionary objectForKey:@"id"]];
			task.position = [dictionary objectForKey:@"position"];
		}
		[[CDKTask mainContext] save:nil];
	}];

	// Bind to user update
	[self.userChannel bindToEvent:@"user-update" block:^(id message) {
		CDKUser *user = [CDKUser objectWithDictionary:message];
		[user save];
	}];
}


#pragma mark - Singleton

+ (CDKPushController *)sharedController {
	static CDKPushController *sharedController = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedController = [[self alloc] init];
	});
	return sharedController;
}


+ (void)setDevelopmentModeEnabled:(BOOL)enabled {
	__developmentMode = enabled;
}


#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
		_client = [[BLYClient alloc] initWithAppKey:(__developmentMode ? kCDKDevelopmentPusherAPIKey : kCDKPusherAPIKey) delegate:self];

		self.userID = [CDKUser currentUser].remoteID.description;

		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(_userChanged:) name:kCDKCurrentUserChangedNotificationName object:nil];
		
#if TARGET_OS_IPHONE
		[notificationCenter addObserver:self selector:@selector(_appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(_appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
#endif

		_reachability = [Reachability reachabilityWithHostname:@"ws.pusherapp.com"];
		[_reachability startNotifier];
		[notificationCenter addObserver:self selector:@selector(_reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	}
	return self;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.client disconnect];
}


#pragma mark - Private

- (void)_userChanged:(NSNotification *)notification {
	self.userID = [CDKUser currentUser].remoteID.description;
}


- (void)_appDidEnterBackground:(NSNotification *)notificaiton {
	[self.client disconnect];
}


- (void)_appDidBecomeActive:(NSNotification *)notification {
	[self.client connect];
}


- (void)_reachabilityChanged:(NSNotification *)notification {
	if ([_reachability isReachable]) {
		[self.client connect];
	} else {
		[self.client disconnect];
	}
}


#pragma mark - BLYClientDelegate

- (void)bullyClientDidConnect:(BLYClient *)client {
	[[CDKHTTPClient sharedClient] setDefaultHeader:@"X-Pusher-Socket-ID" value:client.socketID];
}


- (void)bullyClientDidDisconnect:(BLYClient *)client {
	if ([_reachability isReachable]) {
		[client connect];
	}
}

@end
