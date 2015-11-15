//
//  CCTopicReplyCell.h
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicPostModel.h"

@interface CCTopicReplyCell : UITableViewCell

@property (nonatomic, strong) CCTopicPostModel *post;
@property (nonatomic, strong) CCTopicPostModel *replyToPost;
@property (nonatomic, assign) UINavigationController *nav;
@property (nonatomic, assign) CGFloat textHeight;

@property (nonatomic, copy) void (^reloadCellBlock)();

+ (CGFloat)getCellHeightWithPostModel:(CCTopicPostModel *)post;

@end
