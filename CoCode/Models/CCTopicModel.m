//
//  CCTopicModel.m
//  CoCode
//
//  Created by wuxueqian on 15/11/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicModel.h"
#import "CCHelper.h"
#import "CCMemberModel.h"
#import "CCTopicPostModel.h"

@implementation CCTopicModel

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        self.topicID = [dict objectForKey:@"id"];
        self.topicTitle = [dict objectForKey:@"title"];
        self.topicSlug = [dict objectForKey:@"slug"];
        self.topicPostsCount = [dict objectForKey:@"posts_count"];
        self.topicThumbImage = [dict objectForKey:@"image_url"];
        self.topicCreatedTime = [CCHelper localDateWithString:[dict objectForKey:@"created_at"]];
        self.topicLastRepliedTime = [CCHelper localDateWithString:[dict objectForKey:@"last_posted_at"]];
        self.isPinned = [[dict objectForKey:@"pinned"] boolValue];
        self.isClosed = [[dict objectForKey:@"closed"] boolValue];
        self.isBookmarked = [dict objectForKey:@"bookmarked"] != [NSNull null]?[[dict objectForKey:@"bookmarked"] boolValue]:NO;
        self.isLiked = [dict objectForKey:@"liked"] != [NSNull null]?[[dict objectForKey:@"liked"] boolValue]:NO;
        self.topicViews = [dict objectForKey:@"views"];
        self.topicLikeCount = [dict objectForKey:@"like_count"];
        self.topicLastReplier = [dict objectForKey:@"last_poster_username"];
        self.topicCategoryID = [dict objectForKey:@"category_id"];
        self.topicTags = [dict objectForKey:@"tags"];
        self.topicPosters = [dict objectForKey:@"posters"];
        self.topicCellHeight = 60.0; //TODO default cell height
        self.topicAuthorID = [self.topicPosters[0] objectForKey:@"user_id"];
        //self.topicAuthorName = @"";
        //self.topicAuthorAvatar = @"";
    }
    return self;
}

//From Single Topic JSON data
- (instancetype)initWithDetailedDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        self.topicID = [dict objectForKey:@"id"];
        self.topicTitle = [dict objectForKey:@"title"];
        self.topicSlug = [dict objectForKey:@"slug"];
        self.topicPostsCount = [dict objectForKey:@"posts_count"];
        self.topicCreatedTime = [CCHelper localDateWithString:[dict objectForKey:@"created_at"]];
        self.topicLastRepliedTime = [CCHelper localDateWithString:[dict objectForKey:@"last_posted_at"]];
        self.isPinned = [[dict objectForKey:@"pinned"] boolValue];
        self.isClosed = [[dict objectForKey:@"closed"] boolValue];
        self.isBookmarked = [dict objectForKey:@"bookmarked"] != [NSNull null]?[[dict objectForKey:@"bookmarked"] boolValue]:NO;
        self.topicViews = [dict objectForKey:@"views"];
        self.topicLikeCount = [dict objectForKey:@"like_count"];
        self.topicCategoryID = [dict objectForKey:@"category_id"];
        self.topicCategory = [[CCCategoryModel alloc] initWithDict:[CCHelper getCategoryInfoFromPlistForID:self.topicCategoryID]];
        self.topicTags = [dict objectForKey:@"tags"];
        self.topicAuthorID = [self.topicPosters[0] objectForKey:@"user_id"];
        NSDictionary *authorDict = [[dict objectForKey:@"details"] objectForKey:@"created_by"];
        CCMemberModel *member = [[CCMemberModel alloc] initWithPosterDictionary:authorDict];
        self.topicAuthorName = member.memberUserName;
        self.topicAuthorAvatar = member.memberAvatarLarge;
        
        self.topicPostIDs = [[dict objectForKey:@"post_stream"] objectForKey:@"stream"];
        
        NSMutableArray *posts = [NSMutableArray array];
        NSArray *stream_posts = [[dict objectForKey:@"post_stream"] objectForKey:@"posts"];
        for (NSDictionary *post in stream_posts) {
            CCTopicPostModel *model = [[CCTopicPostModel alloc] initWithDictionary:post];
            [posts addObject:model];
        }
        self.posts = [NSArray arrayWithArray:posts];
        
        CCTopicPostModel *post = posts[0];
        
        CCMemberModel *author = [[CCMemberModel alloc] init];
        author.memberID = post.postUserID;
        author.memberName = post.postUserDisplayname;
        author.memberUserName = post.postUsername;
        author.memberAvatarLarge = post.postUserAvatar;
        
        self.author = author;

    }
    return self;
}

+ (CCTopicModel *)getTopicModelFromResponseObject:(id)responseObject{
    CCTopicModel *topic;
    
    topic = [[CCTopicModel alloc] initWithDetailedDictionary:(NSDictionary *)responseObject];
    
    if (topic) {
        return topic;
    }
    return nil;
}

@end


@implementation CCTopicList

- (instancetype)initWithTopicsArray:(NSArray *)topics postersArray:(NSArray *)posters{
    if (self = [super init]) {
        NSMutableArray *list = [NSMutableArray new];
        for (NSDictionary *dict in topics) {
            CCTopicModel *topic = [[CCTopicModel alloc] initWithDictionary:dict];
            [list addObject:topic];
        }
        self.list = list;
        NSMutableDictionary *posterDicts = [NSMutableDictionary dictionary];
        for (NSDictionary *dict in posters) {
            CCMemberModel *poster = [[CCMemberModel alloc] initWithPosterDictionary:dict];
            [posterDicts setObject:poster forKey:[NSString stringWithFormat:@"ID%d",(int)poster.memberID]];
        }
        self.posters = [NSDictionary dictionaryWithDictionary:posterDicts];
    }
    
    return self;
}

+ (CCTopicList *)getTopicListFromResponseObject:(id)responseObject{
    
    CCTopicList *topicList;
    
    @autoreleasepool {
        NSArray *posters = [responseObject objectForKey:@"users"];
        NSArray *topics = [[responseObject objectForKey:@"topic_list"] objectForKey:@"topics"];
        topicList = [[CCTopicList alloc] initWithTopicsArray:topics postersArray:posters];
    }
    if (topicList.list.count > 0) {
        return topicList;
    }
    return nil;
}


@end