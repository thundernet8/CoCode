//
//  CCTopicListCell.h
//  CoCode
//
//  Created by wuxueqian on 15/11/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTopicModel.h"

@interface CCTopicListCell : UITableViewCell

@property (nonatomic, strong) CCTopicModel *topic;
@property (nonatomic, assign, setter=ifUnderCategory:) BOOL inCategory; // If it is under a single category view, do not show the category label
@property (nonatomic, assign) UINavigationController *navi;

+ (CGFloat)getCellHeightWithTopicModel:(CCTopicModel *)topic;

@end
