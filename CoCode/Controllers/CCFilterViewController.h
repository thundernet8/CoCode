//
//  PopTableViewController.h
//  CoCode
//
//  Created by wuxueqian on 15/11/9.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//


@interface CCFilterViewController : UIViewController

@property (nonatomic, copy) void (^onItemSelected)(NSDictionary *);
@property (nonatomic, copy) void (^onCancel)();
@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, assign) NSInteger tag;

@end
