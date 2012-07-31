//
//  CDKTask.h
//  CheddarKit
//
//  Created by Sam Soffes on 4/5/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "CDKRemoteManagedObject.h"

@class CDKUser;
@class CDKList;
@class CDKTag;
@class NSAttributedString;
@class NSMutableAttributedString;

@interface CDKTask : CDKRemoteManagedObject

@property (nonatomic, strong) NSDate *archivedAt;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *displayText;
@property (nonatomic, strong) NSDictionary *entities;
@property (nonatomic, strong) NSNumber *position;
@property (nonatomic, strong) NSDate *completedAt;
@property (nonatomic, strong) CDKUser *user;
@property (nonatomic, strong) CDKList *list;
@property (nonatomic, strong) NSSet *tags;

- (BOOL)isCompleted;
- (void)toggleCompleted;
- (BOOL)hasTag:(CDKTag *)tag;
- (BOOL)hasTags:(NSArray *)tags;

@end


@interface CDKTask (CoreDataGeneratedAccessors)
- (void)addTagsObject:(CDKTag *)value;
- (void)removeTagsObject:(CDKTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;
@end
