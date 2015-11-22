//
//  CCSettingViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCSettingViewController.h"
#import "CCDataManager.h"
#import <SVProgressHUD.h>
#import "CCSettingManager.h"

@interface CCSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL isLogged;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSString *cacheSizeText;

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
    
    [self configureNotification];
    
    [self statisticCache];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.tableView.contentInsetTop = 64.0;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
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

- (void)configureNotification{
    [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.isLogged = [CCDataManager sharedManager].user.isLogin;
        [self.tableView reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLogoutSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.isLogged = [CCDataManager sharedManager].user.isLogin;
        [self.tableView reloadData];
    }];
}

#pragma mark - TableView Delegate and Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                
                break;
                
            case 1:
                
                break;
                
            case 2:
                [self clearCache];
                break;
                
            default:
                break;
        }
    }
    
    if (indexPath.section == 2) {

    }
    
    if (indexPath.section == 3) {
        if (self.isLogged) {
            [[CCDataManager sharedManager] userLogout];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
        }
        
    }
}


#pragma mark - Configure Cell

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    cell.textLabel.textColor = [UIColor colorWithRed:0.208 green:0.212 blue:0.224 alpha:1.000];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLocalizedString(@"My Account", nil);
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [self configureThemeSwithCell:cell];
                break;
                
            case 1:
                [self configurePicDownloadModeSwitchCell:cell];
                break;
                
            case 2:
                [self configureClearCacheCell:cell];
                break;
                
            default:
                break;
        }
    }
    
    if (indexPath.section == 2) {
        cell.textLabel.text = NSLocalizedString(@"About CoCode", nil);
    }
    
    if (indexPath.section == 3) {

        UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2.0-60.0, 0.0, 120.0, 50.0)];
        cellLabel.text = self.isLogged ? NSLocalizedString(@"Logout Account", nil) : NSLocalizedString(@"Login", nil);
        cellLabel.textAlignment = NSTextAlignmentCenter;
        cellLabel.textColor = [UIColor colorWithRed:1.000 green:0.400 blue:0.400 alpha:1.000];
        
        [cell.contentView addSubview:cellLabel];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Accessories

- (void)configureThemeSwithCell:(UITableViewCell *)cell{
    cell.textLabel.text = NSLocalizedString(@"Night Mode", nil);
    
    if ([cell.contentView viewWithTag:1]) {
        [[cell.contentView viewWithTag:1] removeFromSuperview];
    }
    
    UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-68.0, 10.0, 50.0, 30.0)];
    switchButton.tag = 1;
    
    switchButton.on = [CCSettingManager sharedManager].theme == CCThemeNight;
    
    [switchButton bk_addEventHandler:^(id sender) {
        switchButton.enabled = NO;
        if (switchButton.isOn) {
            [[CCSettingManager sharedManager] setTheme:CCThemeNight];
        }else{
            [[CCSettingManager sharedManager] setTheme:CCThemeDefault];
        }
        switchButton.enabled = YES;
    } forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:switchButton];
    
}

- (void)configurePicDownloadModeSwitchCell:(UITableViewCell *)cell{
    cell.textLabel.text = NSLocalizedString(@"Text Mode", nil);
    
    if ([cell.contentView viewWithTag:1]) {
        [[cell.contentView viewWithTag:1] removeFromSuperview];
    }
    
    UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-68.0, 10.0, 50.0, 30.0)];
    switchButton.tag = 1;
    
    switchButton.on = [CCSettingManager sharedManager].nonePicsMode;
    
    [switchButton bk_addEventHandler:^(id sender) {
        switchButton.enabled = NO;
        if (switchButton.isOn) {
            [[CCSettingManager sharedManager] setNonePicsMode:YES];
        }else{
            [[CCSettingManager sharedManager] setNonePicsMode:NO];
        }
        switchButton.enabled = YES;
    } forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:switchButton];

}

- (void)configureClearCacheCell:(UITableViewCell *)cell{
    
    if ([cell.contentView viewWithTag:1]) {
        [[cell.contentView viewWithTag:1] removeFromSuperview];
    }
    
    cell.textLabel.text = NSLocalizedString(@"Clear Cache", nil);
    UILabel *cacheSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, 0.0, 80.0, 50.0)];
    cacheSizeLabel.tag = 1;
    cacheSizeLabel.text = self.cacheSizeText;
    cacheSizeLabel.textColor = [UIColor colorWithRed:1.000 green:0.400 blue:0.400 alpha:1.000];
    cacheSizeLabel.textAlignment = NSTextAlignmentRight;
    
    [cell addSubview:cacheSizeLabel];
}

- (void)statisticCache
{

    //SDWebImage Cache
    __block float sdCacheSize = 0;
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        sdCacheSize += totalSize;
        //Convert to MB
        float mbSize = sdCacheSize/(1024*1024);
        self.cacheSizeText = [NSString stringWithFormat:@"%0.2f MB", mbSize];
        
        [self.tableView reloadData];
    }];

}

- (void)clearCache{
    //SDWebImageCache
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    
    [self statisticCache];

    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.800]];
    [SVProgressHUD setForegroundColor:kWhiteColor];
    [SVProgressHUD showImage:nil status:NSLocalizedString(@"Clear Cache Success", nil)];
}

@end
