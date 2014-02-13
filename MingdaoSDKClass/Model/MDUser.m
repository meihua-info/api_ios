//
//  MDUser.m
//  MingdaoSDK
//
//  Created by Wee Tom on 13-6-3.
//  Copyright (c) 2013年 WeeTomProduct. All rights reserved.
//

#import "MDUser.h"

@implementation MDUser
- (MDUser *)initWithDictionary:(NSDictionary *)aDic
{
    self = [super init];
    if (self) {
        self.objectID = [aDic objectForKey:@"id"];
        self.objectName = [aDic objectForKey:@"name"];
        self.avatar = [aDic objectForKey:@"avstar"];
        self.avatar100 = [aDic objectForKey:@"avstar100"];
        if (!self.avatar100) {
            self.avatar100 = self.avatar;
        }
        self.email = [aDic objectForKey:@"email"];
        self.grade = [aDic objectForKey:@"grade"];
        self.mark = [aDic objectForKey:@"mark"];
        self.birth = [aDic objectForKey:@"birth"];
        self.gender = [[aDic objectForKey:@"gender"] integerValue];
        self.company = [aDic objectForKey:@"company"];
        self.department = [aDic objectForKey:@"department"];
        self.job = [aDic objectForKey:@"job"];
        self.mobilePhoneNumber = [aDic objectForKey:@"mobile_phone"];
        NSRange range = [self.mobilePhoneNumber rangeOfString:@"*"];
        if (((range.location + range.length )< self.mobilePhoneNumber.length)
            && range.location > 0) {
            self.isMobilePhoneNumberVisible = NO;
        } else if (self.mobilePhoneNumber.length > 0) {
            self.isMobilePhoneNumberVisible = YES;
        } else {
            self.isMobilePhoneNumberVisible = NO;
        }
        self.workPhoneNumber = [aDic objectForKey:@"work_phone"];
        self.isFollowed = [[aDic objectForKey:@"followed_status"] boolValue];
        self.egroup = [[aDic objectForKey:@"egroup"] boolValue];
        self.licence = [[aDic objectForKey:@"license"] integerValue];
        self.status = [[aDic objectForKey:@"status"] integerValue];
        self.jobs = [aDic objectForKey:@"jobs"];
        self.educations = [aDic objectForKey:@"educations"];
        self.unreadMessageCount = [[aDic objectForKey:@"unreadmessage_count"] integerValue];
        self.messageCount = [[aDic objectForKey:@"message_count"] integerValue];
        
        if ([aDic objectForKey:@"project"]) {
            self.project = [[MDCompany alloc] initWithDictionary:[aDic objectForKey:@"project"]];
        }
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        MDUser *aUser = (MDUser *)object;
        if ([[self.objectID lowercaseString] isEqualToString:[aUser.objectID lowercaseString]]) {
            return YES;
        }
    }
    
    return NO;
}

- (id)copy
{
    id object = [[[self class] alloc] init];
    MDUser *copyObject = object;
    copyObject.objectID = [self.objectID copy];
    copyObject.objectName = [self.objectName copy];
    copyObject.avatar = [self.avatar copy];
    copyObject.avatar100 = [self.avatar100 copy];
    copyObject.email = [self.email copy];
    copyObject.grade = [self.grade copy];
    copyObject.mark = [self.mark copy];
    copyObject.gender = self.gender;
    copyObject.birth = [self.birth copy];
    copyObject.company = [self.company copy];
    copyObject.department = [self.department copy];
    copyObject.job = [self.job copy];
    copyObject.mobilePhoneNumber = [self.mobilePhoneNumber copy];
    copyObject.workPhoneNumber = [self.workPhoneNumber copy];
    copyObject.isMobilePhoneNumberVisible = self.isMobilePhoneNumberVisible;
    copyObject.isFollowed = self.isFollowed;
    copyObject.licence = self.licence;
    copyObject.status = self.status;
    copyObject.unreadMessageCount = self.unreadMessageCount;
    copyObject.messageCount = self.messageCount;
    copyObject.jobs = [self.jobs copy];
    copyObject.educations = [self.educations copy];
    copyObject.project = [self.project copy];
    return copyObject;
}

@end
