//
//  TopicRepliesViewController.h
//  CoCode
//
//  Created by wuxueqian on 15/11/15.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SCPullRefreshViewController.h"
#import "CCTopicModel.h"
#import "CCTopicPostModel.h"

@interface CCTopicRepliesViewController : SCPullRefreshViewController

@property (nonatomic, strong) CCTopicModel *topic;
//@property (nonatomic, copy) void (^shouldShowReplyEditorBlock)(CCTopicPostModel *);

@end
