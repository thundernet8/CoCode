//
//  CCTopicPostModel.m
//  CoCode
//
//  Created by wuxueqian on 15/11/11.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicPostModel.h"

@implementation CCTopicPostModel

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        self.postID = [dict objectForKey:@"id"];
        self.postUserID = [dict objectForKey:@"user_id"];
        self.postUsername = [dict objectForKey:@"username"];
        self.postUserDisplayname = [dict objectForKey:@"name"] == [NSNull null] ? @"" : [dict objectForKey:@"name"];
        self.postUserDeleted = [[dict objectForKey:@"user_deleted"] boolValue];
        NSString *avatar = [dict objectForKey:@"avatar_template"];
        self.postUserAvatar = [CCHelper getAvatarFromTemplate:avatar withSize:60];
        self.postCreatedTime = [CCHelper localDateWithString:[dict objectForKey:@"created_at"]];
        self.postContent = [dict objectForKey:@"cooked"];
        self.postNumber = [dict objectForKey:@"post_number"];
        self.postType = [dict objectForKey:@"post_type"];
        self.postUpdateTime = [CCHelper localDateWithString:[dict objectForKey:@"updated_at"]];
        self.postReplyCount = [[dict objectForKey:@"reply_count"] integerValue];
        self.postReplyTo = [dict objectForKey:@"reply_to_post_number"];
        self.postQuoteCount = [[dict objectForKey:@"quote_count"] integerValue];
        self.postReads = [[dict objectForKey:@"reads"] integerValue];
        self.postYours = [[dict objectForKey:@"yours"] boolValue];
        self.postTopicID = [dict objectForKey:@"topic_id"];
        self.postCanEdit = [[dict objectForKey:@"can_edit"] boolValue];
        self.postCanDelete = [[dict objectForKey:@"can_delete"] boolValue];
        self.postBookmarked = [dict objectForKey:@"bookmarked"] != [NSNull null] ? [[dict objectForKey:@"bookmarked"] boolValue] : NO;
        
        NSArray *actions = [dict objectForKey:@"actions_summary"];
        self.postLiked = actions.count > 0 && [actions[0] objectForKey:@"acted"] != [NSNull null] ? [[actions[0] objectForKey:@"acted"] boolValue] : NO;
        self.postLikeCount = actions.count > 0 ? [[actions[0] objectForKey:@"count"] integerValue] : 0;

    }
    return self;
}

+ (NSArray *)getTopicReplyListWithResponseObject:(NSDictionary *)responseObject{
    
    if (!responseObject || ![responseObject objectForKey:@"post_stream"]) {
        return nil;
    }
    NSArray *posts = [[responseObject objectForKey:@"post_stream"] objectForKey:@"posts"];
    
    NSMutableArray *tempReplyList = [NSMutableArray array];
    
    for (NSDictionary *replyPostDict in posts) {
        
        CCTopicPostModel *replyPost = [[CCTopicPostModel alloc] initWithDictionary:replyPostDict];
        [tempReplyList addObject:replyPost];
    }
    
    NSArray *replyList = [NSArray arrayWithArray:tempReplyList];
    
    return replyList;
    
}

@end
