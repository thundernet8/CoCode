//
//  CCMemberProfileViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/11/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMemberProfileViewController.h"

@interface CCMemberProfileViewController ()

@end

@implementation CCMemberProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sc_navigationItem.leftBarButtonItem = self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_back"] imageWithTintColor:kWhiteColor] style:SCBarButtonItemStylePlain handler:^(id sender) {
        [self.navigationController popViewControllerAnimated:YES];
    }];

}



@end
