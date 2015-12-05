//
//  CCMemberPostListCell.h
//  CoCode
//
//  Created by wuxueqian on 15/12/5.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicPostModel.h"

@interface CCMemberPostListCell : UITableViewCell

@property (nonatomic, strong) CCTopicPostModel *post;

+ (CGFloat)getCellHeightWithPostModel:(CCTopicPostModel *)model;

@end
