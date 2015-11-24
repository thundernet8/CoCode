//
//  CCNotificationListModel.h
//  CoCode
//
//  Created by wuxueqian on 15/11/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCNotificationListModel : NSObject

@property (nonatomic, copy) NSArray *list;
@property (nonatomic, assign) NSInteger totalCount;


+ (CCNotificationListModel *)getNotificationListFromResponseObject:(id)responseObject;

@end
