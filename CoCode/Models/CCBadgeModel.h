//
//  CCBadgeModel.h
//  CoCode
//
//  Created by wuxueqian on 15/11/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCBadgeModel : NSObject

@property (nonatomic, copy) NSNumber *badgeNotificationID;
@property (nonatomic, copy) NSNumber *notificationType;
@property (nonatomic, assign) BOOL isRead;
@property (nonatomic, copy) NSDate *createdTime;
@property (nonatomic, copy) NSNumber *badgeID;
@property (nonatomic, copy) NSString *badgeName;
@property (nonatomic, copy) NSString *fullMessage;

- (instancetype) initWithNotificationDict:(NSDictionary *)dict;

@end
