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
#import "CCTagModel.h"
#import "CCNotificationListModel.h"

typedef NS_ENUM(NSInteger, CCErrorType) {
    
    CCErrorTypeNoOnceAndNext            = 900,
    CCErrorTypeLoginFailure             = 901,
    CCErrorTypeRequestFailure           = 902,
    CCErrorTypeGetFeedURLFailure        = 903,
    CCErrorTypeGetTopicListFailure      = 904,
    CCErrorTypeGetNotificationFailure   = 905,
    CCErrorTypeGetFavUrlFailure         = 906,
    CCErrorTypeGetMemberReplyFailure    = 907,
    CCErrorTypeGetTopicTokenFailure     = 908,
    CCErrorTypeGetCheckInURLFailure     = 909,
    CCErrorTypeGetTopicError            = 910,
    CCErrorTypeGetTagsFailure           = 911,
    CCErrorTypeGetCSRFTokenFailure      = 912,
    CCErrorTypeGetNotificationsFailure  = 913
    
};

@interface CCDataManager : NSObject

@property (nonatomic, strong) CCUserModel *user;

+ (instancetype)sharedManager;

//Fetch data

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

- (NSURLSessionDataTask *)getTopicListWithPage:(NSInteger)page
                                   categoryUrl:(NSURL *)categoryUrl
                                       success:(void (^)(CCTopicList *list))success
                                       failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getTagsSuccess:(void (^)(CCTagsModel *tagsModel))success
                                 failure:(void (^)(NSError *error))failure;

//Login/Logout and Register

- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username
                                   password:(NSString *)password
                                    success:(void (^)(id respondeObject))success
                                    failure:(void (^)(NSError *error))failure;

- (void)userLogout;

//Notifiation
- (NSURLSessionDataTask *)getNotificationListWithPage:(NSInteger)page
                                             username:(NSString *)username
                                              success:(void (^)(CCNotificationListModel *notificationList))success
                                              failure:(void (^)(NSError *error))failure;

@end
