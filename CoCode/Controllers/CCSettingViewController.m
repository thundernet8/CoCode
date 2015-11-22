//
//  CCSettingViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCSettingViewController.h"
#import "CCDataManager.h"

@interface CCSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL isLogged;
@property (nonatomic, strong) UITableView *tableView;


@end

@implementation CCSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.isLogged = [CCDataManager sharedManager].user.isLogin;
    }
    
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self configureTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavi];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.tableView.contentInsetTop = 64.0;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}


#pragma mark - Configuration

- (void)configureNavi{
    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationItem.title = NSLocalizedString(@"Settings", nil);
}

- (void)configureTableView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorColor = kSeparatorColor;
    
    self.tableView.scrollEnabled = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - TableView Delegate and Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return self.isLogged ? 1:0;
            break;
        
        case 1:
            return 3;
            break;
            
        case 2:
            return 1;
            break;
            
        case 3:
            return 1;
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 20.0;
            break;
            
        case 1:
        case 2:
        case 3:
            return 1.0;
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"MoreSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    return [self configureCell:cell atIndexPath:indexPath];
}


#pragma mark - Configure Cell

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLocalizedString(@"My Account", nil);
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [self configureThemeSwithCell];
                break;
                
            case 1:
                [self configurePicDownloadModeSwitchCell];
                break;
                
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Clear Cache", nil);
                break;
                
            default:
                break;
        }
    }
    
    if (indexPath.section == 2) {
        cell.textLabel.text = NSLocalizedString(@"About CoCode", nil);
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Accessories

- (void)configureThemeSwithCell{
    
}

- (void)configurePicDownloadModeSwitchCell{
    
}

@end
