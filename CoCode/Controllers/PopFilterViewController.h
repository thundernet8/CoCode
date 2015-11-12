//
//  PopTableViewController.h
//  CoCode
//
//  Created by wuxueqian on 15/11/9.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//


@interface PopFilterViewController : UIViewController

@property (nonatomic, copy) void (^onItemSelected)(NSInteger);
@property (nonatomic, copy) void (^onCancel)();
@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, assign) NSInteger periodType;

@end
