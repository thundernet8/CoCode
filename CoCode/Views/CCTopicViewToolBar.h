//
//  CCTopicViewToolBar.h
//  CoCode
//
//  Created by wuxueqian on 15/12/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicModel.h"

@interface CCTopicViewToolBar : UIView

@property (nonatomic, strong) CCTopicModel *model;

@property (nonatomic, strong) void (^showCommentsActionBlock)();
@property (nonatomic, strong) void (^showCommentEditorActionBlock)();

@end
