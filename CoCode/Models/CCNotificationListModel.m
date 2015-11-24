//
//  CCNotificationListModel.m
//  CoCode
//
//  Created by wuxueqian on 15/11/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCNotificationListModel.h"

#import "CCMessageModel.h"
#import "CCBadgeModel.h"

@implementation CCNotificationListModel

- (instancetype)initWithNotificationListDict:(NSDictionary *)dict{
    self = [super init];
    
    if (self) {
        self.totalCount = [[dict objectForKey:@"total_rows_notifications"] integerValue];
        
        NSMutableArray *notifications = [NSMutableArray array];
        
        for (NSDictionary *notificationDict in [dict objectForKey:@"notifications"]) {
            if ([[notificationDict objectForKey:@"notification_type"] integerValue] == 6) {
                [notifications addObject:[[CCMessageModel alloc] initWithNotificationDict:notificationDict]];
            }
            if ([[notificationDict objectForKey:@"notification_type"] integerValue] == 12) {
                [notifications addObject:[[CCBadgeModel alloc] initWithNotificationDict:notificationDict]];
            }
        }
        
        self.list = [NSArray arrayWithArray:notifications];
    }
    
    return self;
}

+ (CCNotificationListModel *)getNotificationListFromResponseObject:(id)responseObject{
    
    return [[CCNotificationListModel alloc] initWithNotificationListDict:(NSDictionary *)responseObject];
}

@end
