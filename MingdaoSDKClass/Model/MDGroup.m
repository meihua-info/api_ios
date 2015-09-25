//
//  MDGroup.m
//  MingdaoSDK
//
//  Created by Wee Tom on 13-6-4.
//  Copyright (c) 2013年 WeeTomProduct. All rights reserved.
//

#import "MDGroup.h"

@implementation MDGroup
- (MDGroup *)initWithDictionary:(NSDictionary *)aDic
{
    self = [super init];
    if (self) {
        self.objectID = [aDic objectForKey:@"id"];
        self.objectName = [aDic objectForKey:@"name"];
        self.avatar = [aDic objectForKey:@"avstar"];
        self.about = [aDic objectForKey:@"about"];
        if (![self.about isKindOfClass:[NSString class]]) {
            self.about = @"";
        }
        self.isPublic = [[aDic objectForKey:@"is_public"] boolValue];
        self.status = [[aDic objectForKey:@"status"] intValue];
        self.type = [[aDic objectForKey:@"type"] intValue];
        self.isJoined = [[aDic objectForKey:@"followed_status"] boolValue];
        self.userCount = [[aDic objectForKey:@"user_count"] intValue];
        self.postCount = [[aDic objectForKey:@"post_count"] intValue];
        self.creator = [[MDUser alloc] initWithDictionary:[aDic objectForKey:@"user"]];
        self.isHidden = [[aDic objectForKey:@"isHidden"] boolValue];
        self.admins = [aDic objectForKey:@"admins"];
        self.createTime = [aDic objectForKey:@"create_time"];
        self.isApproval = [[aDic objectForKey:@"isApproval"] boolValue];
        self.isPost = [[aDic objectForKey:@"isPost"] boolValue];
        self.isVerified = [[aDic objectForKey:@"isVerified"] boolValue];
        self.isPush = [[aDic objectForKey:@"isPush"] boolValue];

        
        NSMutableArray *members = [NSMutableArray array];
        for (NSDictionary *dic in aDic[@"users"]) {
            MDUser *user = [[MDUser alloc] initWithDictionary:dic];
            [members addObject:user];
        }
        self.members = members;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        MDGroup *aGroup = (MDGroup *)object;
        if ([[self.objectID lowercaseString] isEqualToString:[aGroup.objectID lowercaseString]]) {
            return YES;
        }
    }
    
    return NO;
}

- (id)copy
{
    id object = [[[self class] alloc] init];
    MDGroup *copyObject = object;
    copyObject.objectID = [self.objectID copy];
    copyObject.objectName = [self.objectName copy];
    copyObject.avatar = [self.avatar copy];
    copyObject.about = [self.about copy];
    copyObject.isPublic = self.isPublic;
    copyObject.status = self.status;
    copyObject.type = self.type;
    copyObject.isJoined = self.isJoined;
    copyObject.isHidden = self.isHidden;
    copyObject.userCount = self.userCount;
    copyObject.postCount = self.postCount;
    copyObject.creator = [self.creator copy];
    copyObject.admins = [self.admins copy];
    copyObject.createTime = [self.createTime copy];
    copyObject.isPost = self.isPost;
    copyObject.isApproval = self.isApproval;
    copyObject.isVerified = self.isVerified;
    copyObject.members = [self.members copy];
    copyObject.department = [self.department copy];
    copyObject.isPush = self.isPush;
    return copyObject;
}
@end
