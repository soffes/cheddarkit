//
//  CDKTag.m
//  CheddarKit
//
//  Created by Sam Soffes on 4/12/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "CDKTag.h"
#import "CDKTask.h"

@implementation CDKTag

@dynamic name;
@dynamic tasks;

+ (NSString *)entityName {
	return @"Tag";
}


+ (NSArray *)defaultSortDescriptors {
	return [NSArray arrayWithObjects:
			[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
			[NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES],
			nil];
}


- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
	self.name = [dictionary objectForKey:@"name"];
}


- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	return YES;
}


+ (CDKTag *)existingTagWithName:(NSString *)name {
	return [self existingTagWithName:name context:nil];
}


+ (CDKTag *)existingTagWithName:(NSString *)name context:(NSManagedObjectContext *)context {
	// Default to the main context
	if (!context) {
		context = [self mainContext];
	}
	
	// Create the fetch request for the ID
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self entityWithContext:context];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	fetchRequest.fetchLimit = 1;
	
	// Execute the fetch request
	NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
	
	// If the object is not found, return nil
	if (results.count == 0) {
		return nil;
	}
	
	// Return the object
	return [results objectAtIndex:0];
}

@end
