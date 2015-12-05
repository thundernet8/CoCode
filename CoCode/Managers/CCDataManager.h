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
#import "CCMessageTopicModel.h"

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
    CCErrorTypeGetNotificationsFailure  = 913,
    CCErrorTypeGetMessagePostsFailure   = 914,
    CCErrorTypePostActionFailure        = 915,
    CCErrorTypeGetReplyListFailure      = 916,
    CCErrorTypeSubmitReplyFailure       = 917,
    CCErrorTypeBookmarkFailure          = 918,
    CCErrorTypeGetMemberPostsFailure    = 919,
    CCErrorTypeGetMemberTopicsFailure   = 920,
    CCErrorTypeGetUserBookmarksFailure  = 921,
    CCErrorTypeGetUserProfileFailure    = 922,
    
};

typedef NS_ENUM(NSInteger, CCPostActionType) {
    
    CCPostActionTypeVote                = 2,
    
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

//Fetch Comments

- (NSURLSessionDataTask *)getTopicReplyListWithTopicID:(NSInteger)topicID inPage:(NSInteger)page replyStream:(NSArray *)stream success:(void (^)(NSArray *replyList))success failure:(void (^)(NSError *error))failure;

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

- (NSURLSessionDataTask *)getMessageTopicPostsWithPage:(NSInteger)page
                                               topicID:(NSNumber *)topicID
                                               success:(void (^)(CCMessageTopicPostsModel *messageTopicPosts, CCMemberModel *sender))success
                                               failure:(void (^)(NSError *error))failure;

//Post Action - e.g. Like

- (NSURLSessionDataTask *)actionForPost:(NSInteger)postID actionType:(CCPostActionType)actionType success:(void (^)(CCTopicPostModel *postModel))success failure:(void (^)(NSError *error))failure;

//Post Action - Bookmark
- (NSURLSessionDataTask *)bookmarkTopic:(NSInteger)topicID
                                success:(void (^)(BOOL collectStatus))success
                                failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)unBookmarkTopic:(NSInteger)topicID
                                  success:(void (^)(BOOL collectStatus))success
                                  failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)bookmarkPost:(NSInteger)postID
                               success:(void (^)(BOOL collectStatus))success
                               failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)unBookmarkPost:(NSInteger)postID
                                 success:(void (^)(BOOL collectStatus))success
                                 failure:(void (^)(NSError *error))failure;

//Reply

- (NSURLSessionDataTask *)submitReplyWithContent:(NSString *)replyContent
                                         toTopic:(CCTopicModel *)topic
                                     replyNested:(BOOL)nestStatus
                                         success:(void (^)(CCTopicPostModel *postModel))success
                                         failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)submitReplyWithContent:(NSString *)replyContent
                                         toTopic:(CCTopicModel *)topic
                                    toPostRankID:(NSNumber *)rankID
                                     replyNested:(BOOL)nestStatus
                                         success:(void (^)(CCTopicPostModel *postModel))success
                                         failure:(void (^)(NSError *error))failure;

//Member's posts

- (NSURLSessionDataTask *)getPostsWithPage:(NSInteger)page
                             forMemberName:(NSString *)username
                                   success:(void (^)(CCMemberPostsModel *model))success
                                   failure:(void (^)(NSError *error))failure;

//Member's topics

- (NSURLSessionDataTask *)getTopicsWithPage:(NSInteger)page
                              forMemberName:(NSString *)username
                                    success:(void (^)(CCMemberTopicsModel *model))success
                                    failure:(void (^)(NSError *error))failure;

//User's bookmark

- (NSURLSessionDataTask *)getMyBookmarksWithPage:(NSInteger)page
                                         success:(void (^) (CCUserBookmarksModel *model))success
                                         failure:(void (^)(NSError *))failure;

//Current user detail

- (NSURLSessionDataTask *)getCurrentUserDetailSuccess:(void (^)(CCUserModel *model))success failure:(void (^)(NSError *))failure;

@end
