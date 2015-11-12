//
//  CCTopicMetaCell.h
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicModel.h"

@interface CCTopicMetaCell : UITableViewCell

@property (nonatomic, strong)CCTopicModel *topic;
@property (nonatomic, assign)UINavigationController *nav;

+ (CGFloat)getCellHeightWithTopicModel:(CCTopicModel *)topic;

@end
