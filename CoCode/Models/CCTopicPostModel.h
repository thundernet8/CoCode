//
//  CCTopicPostModel.h
//  CoCode
//
//  Created by wuxueqian on 15/11/11.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCTopicPostModel : NSObject

@property (nonatomic, copy) NSNumber *postID;
@property (nonatomic, copy) NSNumber *postUserID;
@property (nonatomic, copy) NSString *postUsername;
@property (nonatomic, copy) NSString *postUserDisplayname;
@property (nonatomic, assign) BOOL postUserDeleted;
@property (nonatomic, copy) NSString *postUserAvatar;
@property (nonatomic, copy) NSDate *postCreatedTime;
@property (nonatomic, copy) NSString *postContent;
@property (nonatomic, copy) NSNumber *postNumber;
@property (nonatomic, copy) NSNumber *postType; //default 1
@property (nonatomic, copy) NSDate *postUpdateTime;
@property (nonatomic, assign) NSInteger postReplyCount;
@property (nonatomic, copy) NSNumber *postReplyTo;
@property (nonatomic, assign) NSInteger postQuoteCount;
@property (nonatomic, assign) NSInteger postReads;
@property (nonatomic, assign) BOOL postYours;
@property (nonatomic, copy) NSNumber *postTopicID;
@property (nonatomic, assign) BOOL postCanEdit;
@property (nonatomic, assign) BOOL postCanDelete;
@property (nonatomic, assign) BOOL postBookmarked;
@property (nonatomic, assign) BOOL postLiked;
@property (nonatomic, assign) NSInteger postLikeCount;

@property (nonatomic, copy) NSString *title; //Only for useractions data

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithUserActionsDictionary:(NSDictionary *)dict;

+ (NSArray *)getTopicReplyListWithResponseObject:(NSDictionary *)responseObject; //For fetch comments only

@end
