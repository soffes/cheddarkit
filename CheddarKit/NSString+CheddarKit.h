//
//  NSString+CheddarKit.h
//  CheddarKit
//
//  Created by Sam Soffes on 6/10/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CheddarKit)

- (NSRange)composedRangeWithRange:(NSRange)range;
- (NSString *)composedSubstringWithRange:(NSRange)range;

@end
