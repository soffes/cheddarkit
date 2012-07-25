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
#import "CDKDefines.h"
#import "NSString+CheddarKit.h"

#if TARGET_OS_IPHONE
#import <CoreText/CoreText.h>
//#import "TTTAttributedLabel.h"
#endif

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
	return [self.tags containsObject:tag];
}


- (NSAttributedString *)attributedDisplayText {
	if (!self.displayText) {
		if (!self.text) {
			return nil;
		}
		return [[NSAttributedString alloc] initWithString:self.text];
	}
	
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.displayText];
	CTFontRef regularFont = CTFontCreateWithName((__bridge CFStringRef)kCDKRegularFontName, 20.0f, NULL);
	if (regularFont) {
		[attributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)regularFont range:NSMakeRange(0, self.displayText.length)];
	}
	[self addEntitiesToAttributedString:attributedString];
	return attributedString;
}


- (void)addEntitiesToAttributedString:(NSMutableAttributedString *)attributedString {
	// TODO: Cache fonts
	CTFontRef italicFont = NULL;
	CTFontRef boldFont = NULL;
	CTFontRef boldItalicFont = NULL;
	CTFontRef codeFont = NULL;
	
	// Add entities
	for (NSDictionary *entity in self.entities) {
		NSArray *indices = [entity objectForKey:@"display_indices"];
		NSRange range = NSMakeRange([[indices objectAtIndex:0] unsignedIntegerValue], 0);
		range.length = [[indices objectAtIndex:1] unsignedIntegerValue] - range.location;
		range = [attributedString.string composedRangeWithRange:range];
		
		// Skip malformed entities
		if (range.length > self.displayText.length) {
			continue;
		}
		
		NSString *type = [entity objectForKey:@"type"];
		
		// Italic
		if ([type isEqualToString:@"emphasis"]) {
			if (!italicFont) {
				italicFont = CTFontCreateWithName((__bridge CFStringRef)kCDKItalicFontName, 20.0f, NULL);
			}
			[attributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:range];
		}
		
		// Bold
		else if ([type isEqualToString:@"double_emphasis"]) {
			if (!boldFont) {
				boldFont = CTFontCreateWithName((__bridge CFStringRef)kCDKBoldFontName, 20.0f, NULL);
			}
			[attributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:range];
		}
		
		// Bold Italic
		else if ([type isEqualToString:@"triple_emphasis"]) {
			if (!boldItalicFont) {
				boldItalicFont = CTFontCreateWithName((__bridge CFStringRef)kCDKBoldItalicFontName, 20.0f, NULL);
			}
			[attributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)boldItalicFont range:range];
		}
		
#if TARGET_OS_IPHONE
		// Strikethrough
//		else if ([type isEqualToString:@"strikethrough"]) {
//			[attributedString addAttribute:kTTTStrikeOutAttributeName value:[NSNumber numberWithBool:YES] range:range];
//		}
#endif
		
		// Code
		else if ([type isEqualToString:@"code"]) {
			if (!codeFont) {
				codeFont = CTFontCreateWithName((__bridge CFStringRef)@"Courier", 20.0f, NULL);
			}
			[attributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)codeFont range:range];
		}
	}
	
	if (italicFont) {
		CFRelease(italicFont);
	}
	
	if (boldFont) {
		CFRelease(boldFont);
	}
	
	if (boldItalicFont) {
		CFRelease(boldItalicFont);
	}
	
	if (codeFont) {
		CFRelease(codeFont);
	}
}

@end
