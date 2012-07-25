//
//  NSDictionary+CheddarKit.m
//  CheddarKit
//
//  Created by Sam Soffes on 6/4/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "NSDictionary+CheddarKit.h"

@implementation NSDictionary (CheddarKit)


- (id)safeObjectForKey:(id)key {
	id value = [self valueForKey:key];
	if (value == [NSNull null]) {
		return nil;
	}
	return value;
}

@end
