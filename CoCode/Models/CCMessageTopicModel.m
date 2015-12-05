//
//  CCMessageTopicModel.m
//  CoCode
//
//  Created by wuxueqian on 15/11/24.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMessageTopicModel.h"
#import "CCHelper.h"
#import "CCMemberModel.h"
#import "CCTopicPostModel.h"

@implementation CCMessageTopicModel

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
        self.topicTags = [dict objectForKey:@"tags"];
        self.topicAuthorID = [self.topicPosters[0] objectForKey:@"user_id"];
        NSDictionary *authorDict = [[dict objectForKey:@"details"] objectForKey:@"created_by"];
        CCMemberModel *member = [[CCMemberModel alloc] initWithPosterDictionary:authorDict];
        self.topicAuthorUserName = member.memberUserName;
        self.topicAuthorName = member.memberName;
        self.topicAuthorAvatar = member.memberAvatarLarge;
        
        //self.topicPostIDs = [[dict objectForKey:@"post_stream"] objectForKey:@"stream"];
        
        NSMutableArray *posts = [NSMutableArray array];
        NSArray *stream_posts = [[dict objectForKey:@"post_stream"] objectForKey:@"posts"];
        for (NSDictionary *post in stream_posts) {
            CCTopicPostModel *model = [[CCTopicPostModel alloc] initWithDictionary:post];
            [posts addObject:model];
        }
        self.posts = [NSArray arrayWithArray:posts];
        self.stream = [[dict objectForKey:@"post_stream"] objectForKey:@"stream"];
        self.streamDesc = [[self.stream reverseObjectEnumerator] allObjects];
        
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

+ (CCMessageTopicModel *)getMessageTopicModelFromResponseObject:(id)responseObject{
    CCMessageTopicModel *topic;
    
    topic = [[CCMessageTopicModel alloc] initWithDetailedDictionary:(NSDictionary *)responseObject];
    
    if (topic) {
        return topic;
    }
    return nil;
}


@end


@implementation CCMessageTopicPostsModel

- (instancetype)initWithDictionary:(NSDictionary *)dict sender:(CCMemberModel *)sender{
    if (self = [super init]) {
        self.topicID = [dict objectForKey:@"id"];
        
        self.stream = [[dict objectForKey:@"post_stream"] objectForKey:@"stream"];
        
        NSMutableArray *posts = [NSMutableArray array];
        NSArray *stream_posts = [[dict objectForKey:@"post_stream"] objectForKey:@"posts"];
        for (NSDictionary *post in stream_posts) {
            CCTopicPostModel *model = [[CCTopicPostModel alloc] initWithDictionary:post];
            [posts addObject:model];
        }
        self.lists = [NSArray arrayWithArray:posts];
        
        self.sender = sender;
        
    }
    return self;
}

+ (CCMessageTopicPostsModel *)getMessageTopicPostsModelFromResponseObject:(id)responseObject sender:(CCMemberModel *)sender{
    
    CCMessageTopicPostsModel *postsModel = [[CCMessageTopicPostsModel alloc] initWithDictionary:(NSDictionary *)responseObject sender:sender];
    
    if (postsModel) {
        return postsModel;
    }
    
    return nil;
}

@end
