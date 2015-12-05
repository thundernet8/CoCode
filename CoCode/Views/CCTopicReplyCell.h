//
//  CCTopicReplyCell.h
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicPostModel.h"
#import "CCTopicModel.h"

@interface CCTopicReplyCell : UITableViewCell

@property (nonatomic, strong) CCTopicModel *topic;
@property (nonatomic, strong) CCTopicPostModel *post;
@property (nonatomic, strong) CCTopicPostModel *replyToPost;
@property (nonatomic, assign) NSInteger rankInList;
@property (nonatomic, assign) UINavigationController *nav;
@property (nonatomic) CGFloat cellHeight;

@property (nonatomic, copy) void (^reloadCellBlock)();

- (void)showActionSheet;
- (CGFloat)getCellHeight;

@end
