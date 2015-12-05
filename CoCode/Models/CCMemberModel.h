//
//  CCMemberModel.h
//  CoCode
//
//  Created by wuxueqian on 15/11/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCMemberModel : NSObject

@property (nonatomic, copy) NSNumber *memberID;
@property (nonatomic, copy) NSString *memberUserName; //Login username
@property (nonatomic, copy) NSString *memberName; //Full name/Nick name
@property (nonatomic, copy) NSString *memberAvatarMini;
@property (nonatomic, copy) NSString *memberAvatarNormal;
@property (nonatomic, copy) NSString *memberAvatarLarge;

//@property (nonatomic, copy) NSString *memberEmail;
@property (nonatomic, copy) NSString *memberIntro;
@property (nonatomic, copy) NSString *memberWebsiteName;
@property (nonatomic, copy) NSString *memberWebsite;

@property (nonatomic, copy) NSDate *memberLastPostTime;
@property (nonatomic, copy) NSDate *memberLastSeenTime;
@property (nonatomic, copy) NSDate *memberCreatedTime;

@property (nonatomic, copy) NSNumber *memberBadgeCount;
@property (nonatomic, copy) NSNumber *memberProfileViewedCount;

- (instancetype)initWithPosterDictionary:(NSDictionary *)dict;
- (instancetype)initWithUserDictionary:(NSDictionary *)dict;

@end

@interface CCMemberPostsModel : NSObject

@property (nonatomic, strong) NSArray *list;

- (instancetype)initWithResponseObject:(NSDictionary *)responseObject;

@end

@interface CCMemberTopicsModel : NSObject

@property (nonatomic, strong) NSArray *list;

- (instancetype)initWithResponseObject:(NSDictionary *)responseObject;

@end
