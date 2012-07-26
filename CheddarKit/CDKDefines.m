//
//  CDKDefines.m
//  CheddarKit
//
//  Created by Sam Soffes on 3/30/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "CDKDefines.h"

#pragma mark - API

NSString *const kCDKAPIScheme = @"https";
NSString *const kCDKAPIHost = @"api.cheddarapp.com";
NSString *const kCDKPusherAPIKey = @"675f10a650f18b4eb0a8";

NSString *const kCDKDevelopmentAPIScheme = @"http";
NSString *const kCDKDevelopmentAPIHost = @"localhost:5000";
NSString *const kCDKDevelopmentPusherAPIKey = @"a02cb793e9d5fb919023";


#pragma mark - User Defaults Keys

NSString *const kCDKCurrentUserIDKey = @"CHCurrentUserID";
NSString *const kCDKCurrentUsernameKey = @"CHCurrentUsername";


#pragma mark - Misc

NSString *const kCDKKeychainServiceName = @"Cheddar";


#pragma mark - Notifications

NSString *const kCDKListDidUpdateNotificationName = @"CHListDidUpdateNotification";
NSString *const kCDKPlusDidChangeNotificationName = @"CHPlusDidChangeNotification";
