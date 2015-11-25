//
//  CCMessageTopicViewController.h
//  CoCode
//
//  Created by wuxueqian on 15/11/24.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SCPullRefreshViewController.h"


@interface CCMessageTopicViewController : SCPullRefreshViewController

@property (nonatomic, strong) NSNumber *messageTopicID;

@property (nonatomic, strong) NSString *senderName;

@end
