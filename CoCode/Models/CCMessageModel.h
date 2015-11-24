//
//  CCMessageModel.h
//  CoCode
//
//  Created by wuxueqian on 15/11/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCMessageModel : NSObject

@property (nonatomic, copy) NSNumber *messageID;
@property (nonatomic, copy) NSNumber *notificationType;
@property (nonatomic, assign) BOOL isRead;
@property (nonatomic, copy) NSDate *createdTime;
@property (nonatomic, copy) NSNumber *postNumber;
@property (nonatomic, copy) NSNumber *topicID;
@property (nonatomic, copy) NSString *slug;
@property (nonatomic, copy) NSString *topicTitle;
@property (nonatomic, copy) NSNumber *originPostID;
@property (nonatomic, copy) NSString *fromUsername;
@property (nonatomic, copy) NSString *fromUserDisplayName;
@property (nonatomic, copy) NSURL *url;

- (instancetype) initWithNotificationDict:(NSDictionary *)dict;

@end
