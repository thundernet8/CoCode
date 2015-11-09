//
//  CCDataManager.h
//  CoCode
//
//  Created by wuxueqian on 15/11/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCUserModel.h"
#import "CCTopicModel.h"

typedef NS_ENUM(NSInteger, CCErrorType) {
    
    CCErrorTypeNoOnceAndNext          = 100,
    CCErrorTypeLoginFailure           = 101,
    CCErrorTypeRequestFailure         = 102,
    CCErrorTypeGetFeedURLFailure      = 103,
    CCErrorTypeGetTopicListFailure    = 104,
    CCErrorTypeGetNotificationFailure = 105,
    CCErrorTypeGetFavUrlFailure       = 106,
    CCErrorTypeGetMemberReplyFailure  = 107,
    CCErrorTypeGetTopicTokenFailure   = 108,
    CCErrorTypeGetCheckInURLFailure   = 109,
    
};

@interface CCDataManager : NSObject

@property (nonatomic, strong) CCUserModel *user;

+ (instancetype)sharedManager;

- (NSURLSessionDataTask *)getTopicListNewestWithPage:(NSInteger)page
                                         success:(void (^)(CCTopicList *list))success
                                         failure:(void (^)(NSError *error))failure;



@end
