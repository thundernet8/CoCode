//
//  CCBadgeModel.m
//  CoCode
//
//  Created by wuxueqian on 15/11/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCBadgeModel.h"

@implementation CCBadgeModel

- (instancetype)initWithNotificationDict:(NSDictionary *)dict{
    self = [super init];
    
    if (self) {
        self.badgeNotificationID = [dict objectForKey:@"id"];
        self.notificationType = @12;
        self.isRead = [[dict objectForKey:@"read"] boolValue];
        self.createdTime = [CCHelper localDateWithString:[dict objectForKey:@"created_at"]];
        self.badgeID = [[dict objectForKey:@"data"]objectForKey:@"badge_id"];
        self.badgeName = [[dict objectForKey:@"data"] objectForKey:@"badge_name"];
        self.fullMessage = [NSString stringWithFormat:@"获得\"%@\"", self.badgeName];
    }
    
    return self;
}

@end
