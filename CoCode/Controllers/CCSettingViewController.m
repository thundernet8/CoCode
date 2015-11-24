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
#import "CCSettingCell.h"

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
    
    [UIApplication sharedApplication].statusBarStyle = kStatusBarStyle;
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
        [self.tableView setNeedsLayout];
        NSLog(@"login");
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLogoutSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.isLogged = [CCDataManager sharedManager].user.isLogin;
        [self.tableView reloadData];
        [self.tableView setNeedsLayout];
        NSLog(@"logout");
    }];
}

#pragma mark - TableView Delegate and Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.isLogged?4:3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return self.isLogged?1:3;
            break;
        
        case 1:
            return self.isLogged?3:1;
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

- (CCSettingCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"MoreSettingCell";
    CCSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[CCSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.switchButton.alpha = 0;
    cell.centerLabel.text = @"";
    cell.rightLabel.text = @"";
    cell.textLabel.text = @"";
    
    return [self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && self.isLogged) {
        
    }
    
    if ((indexPath.section == 1 && self.isLogged)||(indexPath.section == 0 && !self.isLogged)) {
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
    
    if ((indexPath.section == 2 && self.isLogged)||(indexPath.section == 1 && !self.isLogged)) {

    }
    
    if ((indexPath.section == 3 && self.isLogged)||(indexPath.section == 2 && !self.isLogged)) {
        if (self.isLogged) {
            [[CCDataManager sharedManager] userLogout];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
        }
        
    }
}


#pragma mark - Configure Cell

- (CCSettingCell *)configureCell:(CCSettingCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    cell.textLabel.textColor = [UIColor colorWithRed:0.208 green:0.212 blue:0.224 alpha:1.000];
    
    if (indexPath.section == 0 && self.isLogged) {
        cell.textLabel.text = NSLocalizedString(@"My Account", nil);
    }
    
    if ((indexPath.section == 1 && self.isLogged)||(indexPath.section == 0 && !self.isLogged)) {
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
    
    if ((indexPath.section == 2 && self.isLogged)||(indexPath.section == 1 && !self.isLogged)) {
        cell.textLabel.text = NSLocalizedString(@"About CoCode", nil);
    }
    
    if ((indexPath.section == 3 && self.isLogged)||(indexPath.section == 2 && !self.isLogged)) {

        cell.centerLabel.text = self.isLogged ? NSLocalizedString(@"Logout Account", nil) : NSLocalizedString(@"Login", nil);
        cell.centerLabel.textColor = [UIColor colorWithRed:1.000 green:0.400 blue:0.400 alpha:1.000];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kCellHighlightedColor;
    
    return cell;
}

#pragma mark - Accessories

- (void)configureThemeSwithCell:(CCSettingCell *)cell{
    cell.textLabel.text = NSLocalizedString(@"Night Mode", nil);
    
    cell.switchButton.alpha = 1;
    cell.switchButton.onTintColor = RGB(0x3975cf, 1.0);
    cell.switchButton.on = [CCSettingManager sharedManager].theme == CCThemeNight;
    
    [cell.switchButton bk_addEventHandler:^(id sender) {
        cell.switchButton.enabled = NO;
        if (cell.switchButton.isOn) {
            [[CCSettingManager sharedManager] setTheme:CCThemeNight];
        }else{
            [[CCSettingManager sharedManager] setTheme:CCThemeDefault];
        }
        cell.switchButton.enabled = YES;
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configurePicDownloadModeSwitchCell:(CCSettingCell *)cell{
    cell.textLabel.text = NSLocalizedString(@"Text Mode", nil);

    cell.switchButton.alpha = 1;
    cell.switchButton.onTintColor = RGB(0x3975cf, 1.0);
    cell.switchButton.on = [CCSettingManager sharedManager].nonePicsMode;
    [cell.switchButton bk_addEventHandler:^(id sender) {
        cell.switchButton.enabled = NO;
        if (cell.switchButton.isOn) {
            [[CCSettingManager sharedManager] setNonePicsMode:YES];
            NSLog(@"1");
        }else{
            [[CCSettingManager sharedManager] setNonePicsMode:NO];
            NSLog(@"2");
        }
        cell.switchButton.enabled = YES;
    } forControlEvents:UIControlEventTouchUpInside];

}

- (void)configureClearCacheCell:(CCSettingCell *)cell{
    
    cell.textLabel.text = NSLocalizedString(@"Clear Cache", nil);
    //cell.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, 0.0, 80.0, 50.0)];
    cell.rightLabel.text = self.cacheSizeText;
    cell.rightLabel.textColor = [UIColor colorWithRed:1.000 green:0.400 blue:0.400 alpha:1.000];
    cell.rightLabel.textAlignment = NSTextAlignmentRight;
    
    //[cell addSubview:cell.rightLabel];
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
