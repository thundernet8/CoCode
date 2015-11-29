//
//  CCMessagePostCell.h
//  CoCode
//
//  Created by wuxueqian on 15/11/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicPostModel.h"

@interface CCMessagePostCell : UITableViewCell

@property (nonatomic) CGFloat cellHeight;

- (CCMessagePostCell *)configureWithMessagePost:(CCTopicPostModel *)post needTimeLabel:(BOOL)needTimeLabel;

- (CGFloat)getCellHeightOfAll:(BOOL)all;

@end
