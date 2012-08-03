//
//  CDKRemoteManagedObject.h
//  Cheddar
//
//  Created by Sam Soffes on 6/24/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#if TARGET_OS_IPHONE
	#import "SSDataKit.h"
#else
	#import <CheddarKit/SSManagedObject.h>
	#import <CheddarKit/SSRemoteManagedObject.h>
	#import <CheddarKit/NSManagedObjectContext+SSDataKitAdditions.h>
#endif

@class AFJSONRequestOperation;

@interface CDKRemoteManagedObject : SSRemoteManagedObject

- (void)create;
- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

- (void)update;
- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

+ (void)sortWithObjects:(NSArray *)objects;
+ (void)sortWithObjects:(NSArray *)objects success:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

@end
