//
//  CDKPushController.h
//  CheddarKit
//
//  Created by Sam Soffes on 4/9/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLYClient;
@class BLYChannel;

@interface CDKPushController : NSObject

@property (nonatomic, strong, readonly) BLYClient *client;
@property (nonatomic, strong, readonly) BLYChannel *userChannel;

+ (CDKPushController *)sharedController;
+ (void)setDevelopmentModeEnabled:(BOOL)enabled;

@end
