//
//  CCTopicBodyCell.h
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicModel.h"
#import "CCTopicViewController.h"

@interface CCTopicBodyCell : UITableViewCell

@property (nonatomic, strong) CCTopicModel *topic;
@property (nonatomic, assign) UINavigationController *nav;
@property (nonatomic, assign) CCTopicViewController *topicVC;
@property (nonatomic, copy) void (^reloadCellBlcok)();

- (CGFloat)getCellHeight;

@end
