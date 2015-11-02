//
//  CCLatestTopicsViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCLatestViewController.h"

@interface CCLatestViewController ()

@end

@implementation CCLatestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 200.0, 100.0, 20.0)];
    label.text = @"CCLatestViewController";
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)applicationWillResignActive:(NSNotification *)notification

{
    printf("按理说是触发home按下\n");
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    printf("按理说是重新进来后响应\n");
}

@end
