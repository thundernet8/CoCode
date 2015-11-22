//
//  CCTagsViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTagsViewController.h"

#import "CCDataManager.h"

@interface CCTagsViewController ()

@end

@implementation CCTagsViewController

- (void)loadView{
    [super loadView];
    
    [self configureNavi];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureView];
    
//    [[CCDataManager sharedManager] getTagsSuccess:^(CCTagsModel *tagsModel) {
//        NSLog(@"%@",tagsModel.tagList);
//    } failure:^(NSError *error) {
//        
//    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

#pragma mark - Configuration

- (void)configureNavi{
    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_navi_menu"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
    }];
    
    self.sc_navigationItem.title = NSLocalizedString(@"Tags", nil);
}

- (void)configureView{
    self.view.backgroundColor = [UIColor redColor];
    //self.view.frame = CGRectMake(0.0, 0.0, kScreenWidth, kScreenHeight);
    
}

#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    self.view.backgroundColor = kBackgroundColorWhiteDark;
}

@end
