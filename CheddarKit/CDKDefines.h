//
//  CDKDefines.h
//  CheddarKit
//
//  Created by Sam Soffes on 3/30/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef CHDEFINES
#define CHDEFINES

// CDKDispatchRelease
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 || MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
	#define CDKDispatchRelease(queue)
#else
	#define CDKDispatchRelease(queue) dispatch_release(queue)
#endif

// Always use development on the simulator or Mac app (for now)
#define IN_PRODUCTION !TARGET_IPHONE_SIMULATOR && !TARGET_OS_MAC

#pragma mark - API

extern NSString *const kCDKAPIScheme;
extern NSString *const kCDKAPIHost;
extern NSString *const kCDKPusherAPIKey;


#pragma mark - User Defaults Keys

extern NSString *const kCDKCurrentUserIDKey;
extern NSString *const kCDKCurrentUsernameKey;


#pragma mark - Fonts

extern NSString *const kCDKRegularFontName;
extern NSString *const kCDKBoldFontName;
extern NSString *const kCDKBoldItalicFontName;
extern NSString *const kCDKItalicFontName;


#pragma mark - Misc

extern NSString *const kCDKKeychainServiceName;

#pragma mark - Notifications

extern NSString *const kCDKListDidUpdateNotificationName;
extern NSString *const kCDKPlusDidChangeNotificationName;

#endif
