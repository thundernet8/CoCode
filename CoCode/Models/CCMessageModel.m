//
//  CCMessageModel.m
//  CoCode
//
//  Created by wuxueqian on 15/11/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMessageModel.h"

@implementation CCMessageModel

- (instancetype)initWithNotificationDict:(NSDictionary *)dict{
    self = [super init];
    
    if (self) {
        self.messageID = [dict objectForKey:@"id"];
        self.notificationType = @6;
        self.isRead = [[dict objectForKey:@"read"] boolValue];
        self.createdTime = [CCHelper localDateWithString:[dict objectForKey:@"created_at"]];
        self.postNumber = [dict objectForKey:@"post_number"];
        self.topicID = [dict objectForKey:@"topic_id"];
        self.slug = [dict objectForKey:@"slug"];
        self.topicTitle = [[dict objectForKey:@"data"] objectForKey:@"topic_title"];
        self.originPostID = [[dict objectForKey:@"data"] objectForKey:@"original_post_id"];
        self.fromUsername = [[dict objectForKey:@"data"] objectForKey:@"original_username"];
        self.fromUserDisplayName = [[dict objectForKey:@"data"] objectForKey:@"display_username"];
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@t/%@/%d/", kBaseUrl, self.slug, [self.topicID intValue]]];
    }
    
    return self;
}

@end
