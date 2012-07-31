//
//  CDKTask.m
//  CheddarKit
//
//  Created by Sam Soffes on 4/5/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "CDKTask.h"
#import "CDKUser.h"
#import "CDKList.h"
#import "CDKTag.h"
#import "CDKHTTPClient.h"
#import "NSString+CheddarKit.h"

@implementation CDKTask

@dynamic archivedAt;
@dynamic text;
@dynamic displayText;
@synthesize entities;
@dynamic position;
@dynamic completedAt;
@dynamic user;
@dynamic list;
@dynamic tags;

#pragma mark - SSManagedObject

+ (NSString *)entityName {
	return @"Task";
}


+ (NSArray *)defaultSortDescriptors {
	return [NSArray arrayWithObjects:
			[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES],
			[NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES],
			nil];
}


#pragma mark - SSRemoteManagedObject

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
	self.archivedAt = [[self class] parseDate:[dictionary objectForKey:@"archived_at"]];
	self.completedAt = [[self class] parseDate:[dictionary objectForKey:@"completed_at"]];
	self.position = [dictionary objectForKey:@"position"];
	self.text = [dictionary objectForKey:@"text"];
	self.displayText = [dictionary objectForKey:@"display_text"];
	self.entities = [dictionary objectForKey:@"entities"];

	if ([dictionary objectForKey:@"user"]) {
		self.user = [CDKUser objectWithDictionary:[dictionary objectForKey:@"user"] context:self.managedObjectContext];
	}
	
	NSNumber *listID = [dictionary objectForKey:@"list_id"];
	if (listID) {
		self.list = [CDKList objectWithRemoteID:listID context:self.managedObjectContext];
	}

	// Add tags
	NSMutableSet *tags = [[NSMutableSet alloc] init];
	for (NSDictionary *tagDictionary in [dictionary objectForKey:@"tags"]) {
		CDKTag *tag = [CDKTag objectWithDictionary:tagDictionary];
		[tags addObject:tag];
	}
	self.tags = tags;
}


- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	return YES;
}


#pragma mark - CDKRemoteManagedObject

- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *operation, NSError *error))failure {
	[[CDKHTTPClient sharedClient] createTask:self success:^(AFJSONRequestOperation *operation, id responseObject) {
		if (success) {
			success();
		}
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(operation, error);
		}
	}];
}


- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *operation, NSError *error))failure {
	[[CDKHTTPClient sharedClient] updateTask:self success:^(AFJSONRequestOperation *operation, id responseObject) {
		if (success) {
			success();
		}
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(operation, error);
		}
	}];
}


+ (void)sortWithObjects:(NSArray *)objects success:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *operation, NSError *error))failure {
	CDKList *list = [(CDKTask *)[objects objectAtIndex:0] list];
	[[CDKHTTPClient sharedClient] sortTasks:objects inList:list success:^(AFJSONRequestOperation *operation, id responseObject) {
		if (success) {
			success();
		}
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(operation, error);
		}
	}];
}


#pragma mark - Task


- (BOOL)isCompleted {
	return self.completedAt != nil;
}


- (void)toggleCompleted {
	if (self.isCompleted) {
		self.completedAt = nil;
	} else {
		self.completedAt = [NSDate date];
	}
	[self save];
	[self update];
}


- (BOOL)hasTag:(CDKTag *)tag {
	// There has to be a better way to write this
	NSArray *names = [self.tags valueForKey:@"name"];
	NSString *tagName = [tag.name lowercaseString];
	for (NSString *name in names) {
		if ([[name lowercaseString] isEqualToString:tagName]) {
			return YES;
		}
	}
	return NO;
}


- (BOOL)hasTags:(NSArray *)tags {
	// There has to be a better way to write this
	for (CDKTag *tag in tags) {
		if (![self hasTag:tag]) {
			return NO;
		}
	}
	return YES;
}

@end
