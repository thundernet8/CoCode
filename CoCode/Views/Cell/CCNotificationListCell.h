//
//  CCNotificationListCell.h
//  CoCode
//
//  Created by wuxueqian on 15/11/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCNotificationType){
    CCNotificationTypeMessage   = 6,
    CCNotificationTypeBadge     = 12
};

@interface CCNotificationListCell : UITableViewCell

- (CCNotificationListCell *)configureWithNotificationModel:(id)model;

+ (CGFloat)getCellHeightWithNotificationType:(CCNotificationType)type;

@end
