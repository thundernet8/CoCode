//
//  CCMemberModel.m
//  CoCode
//
//  Created by wuxueqian on 15/11/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMemberModel.h"
#import "CCHelper.h"

@implementation CCMemberModel

- (instancetype)initWithPosterDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        self.memberID = [dict objectForKey:@"id"];
        self.memberUserName = [dict objectForKey:@"username"];
        NSString *avatar = [dict objectForKey:@"avatar_template"];
        if ([[avatar substringWithRange:NSMakeRange(0, 30)] isEqualToString:@"https://avatars.discourse.org/"]) {
            avatar = [avatar stringByReplacingOccurrencesOfString:@"{size}" withString:@"60"];
        }else{
            avatar = [@"http://cocode.cc" stringByAppendingString:[avatar stringByReplacingOccurrencesOfString:@"{size}" withString:@"60"]];
        }
        self.memberAvatarLarge = avatar;
    }
    return self;
}

- (instancetype)initWithUserDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        self.memberID = [dict objectForKey:@"id"];
        self.memberUserName = [dict objectForKey:@"username"];
        NSString *avatar = [dict objectForKey:@"avatar_template"];
        if ([[avatar substringWithRange:NSMakeRange(0, 30)] isEqualToString:@"https://avatars.discourse.org/"]) {
            avatar = [avatar stringByReplacingOccurrencesOfString:@"{size}" withString:@"60"];
        }else{
            avatar = [@"http://cocode.cc" stringByAppendingString:[avatar stringByReplacingOccurrencesOfString:@"{size}" withString:@"60"]];
        }
        self.memberAvatarLarge = avatar;
        self.memberName = [dict objectForKey:@"name"];
        self.memberIntro = [dict objectForKey:@"title"];
        self.memberWebsite = [dict objectForKey:@"website_name"];
        self.memberBadgeCount = [dict objectForKey:@"badge_count"];
        self.memberProfileViewedCount = [dict objectForKey:@"profile_view_count"];
        
        //Time related
        self.memberCreatedTime = [CCHelper localDateWithString:[dict objectForKey:@"created_at"]];
        self.memberLastSeenTime = [CCHelper localDateWithString:[dict objectForKey:@"last_seen_at"]];
        self.memberLastPostTime = [CCHelper localDateWithString:[dict objectForKey:@"last_posted_at"]];
    }
    return self;
}

@end
