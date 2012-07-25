//
//  CDKDefines.m
//  CheddarKit
//
//  Created by Sam Soffes on 3/30/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "CDKDefines.h"

#pragma mark - API

#if IN_PRODUCTION
NSString *const kCDKAPIScheme = @"https";
NSString *const kCDKAPIHost = @"api.cheddarapp.com";
NSString *const kCDKPusherAPIKey = @"675f10a650f18b4eb0a8";
#else
NSString *const kCDKAPIScheme = @"http";
NSString *const kCDKAPIHost = @"localhost:5000";
NSString *const kCDKPusherAPIKey = @"a02cb793e9d5fb919023";
#endif


#pragma mark - User Defaults Keys

NSString *const kCDKCurrentUserIDKey = @"CHCurrentUserID";
NSString *const kCDKCurrentUsernameKey = @"CHCurrentUsername";


#pragma mark - Fonts

NSString *const kCDKRegularFontName = @"Gotham-Book";
NSString *const kCDKBoldFontName = @"Gotham-Bold";
NSString *const kCDKBoldItalicFontName = @"Gotham-BoldItalic";
NSString *const kCDKItalicFontName = @"Gotham-BookItalic";


#pragma mark - Misc

NSString *const kCDKKeychainServiceName = @"Cheddar";


#pragma mark - Notifications

NSString *const kCDKListDidUpdateNotificationName = @"CHListDidUpdateNotification";
NSString *const kCDKPlusDidChangeNotificationName = @"CHPlusDidChangeNotification";
