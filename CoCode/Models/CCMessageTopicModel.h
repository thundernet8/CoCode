//
//  CCMessageTopicModel.h
//  CoCode
//
//  Created by wuxueqian on 15/11/24.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCMemberModel.h"

@interface CCMessageTopicModel : NSObject

@property (nonatomic, strong) NSNumber *topicID;
@property (nonatomic, copy) NSString *topicTitle;
@property (nonatomic, copy) NSString *topicSlug;
@property (nonatomic, copy) NSString *topicContent;
@property (nonatomic, strong) NSNumber *topicPostsCount;
@property (nonatomic, copy) NSString *topicThumbImage;
@property (nonatomic, copy) NSDate *topicCreatedTime;
@property (nonatomic, copy) NSDate *topicLastRepliedTime;
@property (nonatomic, assign) BOOL isPinned;
@property (nonatomic, assign) BOOL isClosed;
@property (nonatomic, assign) BOOL isBookmarked;
@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, strong) NSNumber *topicViews;
@property (nonatomic, strong) NSNumber *topicLikeCount;
@property (nonatomic, copy) NSString *topicLastReplier;
@property (nonatomic, strong) NSArray *topicTags;
@property (nonatomic, strong) NSArray *topicPosters;
@property (nonatomic, assign) CGFloat topicCellHeight;
@property (nonatomic, strong) NSNumber *topicAuthorID;
@property (nonatomic, copy) NSString *topicAuthorUserName;
@property (nonatomic, copy) NSString *topicAuthorName;
@property (nonatomic, copy) NSString *topicAuthorAvatar;

//Detailed Topic info
//@property (nonatomic, copy) NSArray *topicPostIDs;
@property (nonatomic, copy) NSArray *topicPosts;


//Posts
@property (nonatomic ,strong) NSArray *posts;
@property (nonatomic, strong) NSArray *stream;
@property (nonatomic, strong) NSArray *streamDesc;

@property (nonatomic, strong) CCMemberModel *author;

+ (CCMessageTopicModel *)getMessageTopicModelFromResponseObject:(id)responseObject;

@end

@interface CCMessageTopicPostsModel : NSObject

@property (nonatomic, strong) NSNumber *topicID;
@property (nonatomic, strong) NSArray *lists;
@property (nonatomic) NSInteger totalCount;
@property (nonatomic, strong) NSArray *stream;
@property (nonatomic, strong) CCMemberModel *sender;

+ (CCMessageTopicPostsModel *)getMessageTopicPostsModelFromResponseObject:(id)responseObject sender:(CCMemberModel *)sender;

@end
