//
//  CCTopicModel.h
//  CoCode
//
//  Created by wuxueqian on 15/11/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef NS_ENUM (NSInteger, CCTopicState) {
//    
//    CCTopicStateUnreadWithReply      = 1 << 0,
//    CCTopicStateUnreadWithoutReply   = 1 << 1,
//    CCTopicStateReadWithoutReply     = 1 << 2,
//    CCTopicStateReadWithReply        = 1 << 3,
//    CCTopicStateReadWithNewReply     = 1 << 4,
//    CCTopicStateRepliedWithNewReply  = 1 << 5,
//    
//};

@interface CCTopicModel : NSObject

@property (nonatomic, assign) NSNumber *topicID;
@property (nonatomic, copy) NSString *topicTitle;
@property (nonatomic, copy) NSString *topicSlug;
@property (nonatomic, copy) NSString *topicContent;
@property (nonatomic, assign) NSNumber *topicPostsCount;
@property (nonatomic, copy) NSString *topicThumbImage;
@property (nonatomic, copy) NSDate *topicCreatedTime;
@property (nonatomic, copy) NSDate *topicLastRepliedTime;
@property (nonatomic, assign) BOOL isPinned;
@property (nonatomic, assign) BOOL isClosed;
@property (nonatomic, assign) BOOL isBookmarked;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) NSNumber *topicViews;
@property (nonatomic, assign) NSNumber *topicLikeCount;
@property (nonatomic, copy) NSString *topicLastReplier;
@property (nonatomic, assign) NSNumber *topicCategoryID;
@property (nonatomic, strong) NSArray *topicTags;
@property (nonatomic, strong) NSArray *topicPosters;
@property (nonatomic, assign) CGFloat topicCellHeight;
@property (nonatomic, assign) NSNumber *topicAuthorID;
@property (nonatomic, copy) NSString *topicAuthorName;
@property (nonatomic, copy) NSString *topicAuthorAvatar;


@end

@interface CCTopicList : NSObject

@property (nonatomic, strong) NSArray *list; //Posts
@property (nonatomic, strong) NSDictionary *posters;

- (instancetype)initWithTopicsArray:(NSArray *)topics postersArray:(NSArray *)posters;

+ (CCTopicList *)getTopicListFromResponseObject:(id)responseObject;

@end

@interface CCTopicPoster : NSObject

@end