//
//  CDKUser.m
//  CheddarKit
//
//  Created by Sam Soffes on 4/5/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "CDKUser.h"
#import "CDKList.h"
#import "CDKTask.h"
#import "SSKeychain.h"
#import "NSDictionary+CheddarKit.h"
#import "CDKDefines.h"

NSString *const kCDKCurrentUserChangedNotificationName = @"CHCurrentUserChangedNotification";
static NSString *const kCDKUserIDKey = @"CDKUserID";
static CDKUser *__currentUser = nil;

@implementation CDKUser

@dynamic firstName;
@dynamic lastName;
@dynamic username;
@dynamic email;
@dynamic tasks;
@dynamic lists;
@dynamic hasPlus;
@synthesize accessToken = _accessToken;


+ (NSString *)entityName {
	return @"User";
}


+ (CDKUser *)currentUser {
	if (!__currentUser) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSNumber *userID = [userDefaults objectForKey:kCDKUserIDKey];
		if (!userID) {
			return nil;
		}

		NSError *error = nil;
		NSString *accessToken = [SSKeychain passwordForService:kCDKKeychainServiceName account:userID.description error:&error];
		if (!accessToken) {
			NSLog(@"[CheddarKit] Failed to get access token: %@", error);
			return nil;
		}

		__currentUser = [self existingObjectWithRemoteID:userID];
		__currentUser.accessToken = accessToken;
	}
	return __currentUser;
}


+ (void)setCurrentUser:(CDKUser *)user {
	if (__currentUser) {
		[SSKeychain deletePasswordForService:kCDKKeychainServiceName account:__currentUser.remoteID.description];
	}

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	if (!user.remoteID || !user.accessToken) {
		__currentUser = nil;
		[userDefaults removeObjectForKey:kCDKUserIDKey];
	} else {
		NSError *error = nil;
		[SSKeychain setPassword:user.accessToken forService:kCDKKeychainServiceName account:user.remoteID.description error:&error];
		if (error) {
			NSLog(@"[CheddarKit] Failed to save access token: %@", error);
		}
		
		__currentUser = user;
		[userDefaults setObject:user.remoteID forKey:kCDKUserIDKey];
	}
	
	[userDefaults synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:kCDKCurrentUserChangedNotificationName object:user];
}


- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
	self.firstName = [dictionary safeObjectForKey:@"first_name"];
	self.lastName = [dictionary safeObjectForKey:@"last_name"];
	self.username = [dictionary safeObjectForKey:@"username"];
	self.email = [dictionary safeObjectForKey:@"email"];
	self.hasPlus = [dictionary safeObjectForKey:@"has_plus"];
}

@end
