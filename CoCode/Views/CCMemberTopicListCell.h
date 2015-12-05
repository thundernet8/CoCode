//
//  CCMemberTopicListCell.h
//  CoCode
//
//  Created by wuxueqian on 15/12/5.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicModel.h"

@interface CCMemberTopicListCell : UITableViewCell

@property (nonatomic, strong) CCTopicModel *topic;

+ (CGFloat)getCellHeightWithTopicModel:(CCTopicModel *)model;

@end
