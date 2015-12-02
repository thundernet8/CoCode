//
//  CCTopicViewReplyInput.h
//  CoCode
//
//  Created by wuxueqian on 15/12/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicModel.h"

@interface CCTopicViewReplyInput : UIView

@property (nonatomic, strong) void (^dismissViewBlock)();
@property (nonatomic, strong) CCTopicModel *model;

- (void)showView;

@end
