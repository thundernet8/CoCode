//
//  CCTopicViewReplyInput.h
//  CoCode
//
//  Created by wuxueqian on 15/12/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicModel.h"
#import "CCTopicPostModel.h"

@interface CCTopicViewReplyInput : UIView

@property (nonatomic, copy) void (^dismissViewBlock)();
@property (nonatomic, strong) CCTopicModel *topic;
@property (nonatomic, strong) CCTopicPostModel *post;

- (void)showView;

@end
