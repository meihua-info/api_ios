//
//  MDProject.h
//  MingdaoSDK
//
//  Created by Wee Tom on 13-6-5.
//  Copyright (c) 2013年 WeeTomProduct. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDUser.h"
#import "MDTaskFolderStage.h"
#import "MDGroup.h"

typedef enum : NSUInteger {
    MDTaskAuthNone = 0,
    MDTaskAuthCharger = 1,
    MDTaskAuthMember = 2,
    MDTaskAuthVisible = 3,
    MDTaskAuthNull = 4,
    MDTaskAuthFolderCharger = 5,
    MDTaskAuthFolderMember = 6,
    MDTaskAuthSubUser = 7,
    MDTaskAuthFolderAdmin = 8,
    MDTaskAuthVisibleGroupMember = 9
} MDTaskAuth;

@interface MDTaskFolder : NSObject
@property (strong, nonatomic) NSString *objectID;
@property (strong, nonatomic) NSString *objectName;

@property (strong, nonatomic) NSString *createDateString;
@property (strong, nonatomic) NSString *deadLine;

@property (assign, nonatomic) int unreadDiscussCount;
@property (assign, nonatomic) int taskInProgressCount;
@property (assign, nonatomic) int taskCompletedCount;

@property (assign, nonatomic) int colorType;

@property (strong, nonatomic) NSString *creatorID;
@property (strong, nonatomic) MDUser *charger;

@property (strong, nonatomic) NSArray *stages;
@property (readonly, nonatomic) BOOL isCompleted;

@property (strong, nonatomic) NSMutableArray *members;
@property (assign ,nonatomic) NSInteger isFavorite;
@property (assign, nonatomic) NSInteger isArchived;
@property (assign, nonatomic) NSInteger isTop;
@property (assign, nonatomic) MDTaskAuth taskAuth;

@property (assign, nonatomic) NSInteger isVisibility;

@property (assign, nonatomic) NSInteger currentUserType;
@property (assign, nonatomic) NSInteger applyCount;

@property (strong, nonatomic) NSString *fileID;
@property (strong, nonatomic) NSMutableArray *groupsArr;

- (MDTaskFolder *)initWithDictionary:(NSDictionary *)aDic;
@end
