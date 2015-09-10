//
//  MDProject.h
//  MingdaoSDK
//
//  Created by Wee Tom on 13-6-3.
//  Copyright (c) 2013年 WeeTomProduct. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MDCompanyTypeFree = 0,
    MDCompanyTypeTrial = 1,
    MDCompanyTypePremium = 2
} MDCompanyType;

@interface MDCompany : NSObject
@property (strong, nonatomic) NSString *objectID;
@property (strong, nonatomic) NSString *objectName;
@property (strong, nonatomic) NSString *nameEn, *logo;
@property (assign, nonatomic) MDCompanyType type;
@property (strong, nonatomic) NSString *expireDays;
- (MDCompany *)initWithDictionary:(NSDictionary *)aDic;
@end
