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
#import "CCTopicPostModel.h"

typedef NS_ENUM(NSInteger, CCErrorType) {
    
    CCErrorTypeNoOnceAndNext          = 900,
    CCErrorTypeLoginFailure           = 901,
    CCErrorTypeRequestFailure         = 902,
    CCErrorTypeGetFeedURLFailure      = 903,
    CCErrorTypeGetTopicListFailure    = 904,
    CCErrorTypeGetNotificationFailure = 905,
    CCErrorTypeGetFavUrlFailure       = 906,
    CCErrorTypeGetMemberReplyFailure  = 907,
    CCErrorTypeGetTopicTokenFailure   = 908,
    CCErrorTypeGetCheckInURLFailure   = 909,
    CCErrorTypeGetTopicError          = 910
    
};

@interface CCDataManager : NSObject

@property (nonatomic, strong) CCUserModel *user;

+ (instancetype)sharedManager;

- (NSURLSessionDataTask *)getTopicListNewestWithPage:(NSInteger)page
                                         success:(void (^)(CCTopicList *list))success
                                         failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getTopicListLatestWithPage:(NSInteger)page
                                             success:(void (^)(CCTopicList *list))success
                                             failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getTopicListHotWithPage:(NSInteger)page
                                         inPeriod:(NSInteger)period
                                             success:(void (^)(CCTopicList *list))success
                                             failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getTopicWithTopicID:(NSInteger)topicID
                                      success:(void (^)(CCTopicModel *topic))success
                                      failure:(void (^)(NSError *error))failure;


@end
