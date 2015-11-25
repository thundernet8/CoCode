//
//  CCMessagePostCell.h
//  CoCode
//
//  Created by wuxueqian on 15/11/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicPostModel.h"

@interface CCMessagePostCell : UITableViewCell


- (CCMessagePostCell *)configureWithMessagePost:(CCTopicPostModel *)post;

+ (CGFloat)getCellHeightWithMessagePost:(CCTopicPostModel *)post;

@end
