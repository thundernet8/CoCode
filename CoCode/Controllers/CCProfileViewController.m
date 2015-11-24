//
//  CCProfileViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCProfileViewController.h"
#import "CCDataManager.h"

#import <MessageUI/MFMailComposeViewController.h>
#import <SVProgressHUD.h>
#import "CCSettingViewController.h"
#import "CCSettingCell.h"
#import "CCNotificationListViewController.h"

#define kAvatarHeight 76.0
#define kAvatarMaskHeight 90.0

@interface CCProfileViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic) BOOL isLogged;

@property (nonatomic) BOOL isMyself;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *avatarMaskView;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *editProfileButton;

@property (nonatomic, strong) UITableView *tableView;


//Rows
@property (nonatomic, strong) NSArray *userRelatedRows;

@end

@implementation CCProfileViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        
        
    }
    
    return self;
}

- (void)loadView{
    [super loadView];
    
    self.view.backgroundColor = RGB(0xf0f1f5, 1.0);
    
    [self configureRowsData];
    
    [self configureTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavi];
    
    [self configureNotification];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configuraton

- (void)configureRowsData{
    self.isLogged = [[kUserDefaults objectForKey:kUserIsLogin] boolValue];
    
    self.isMyself = (!(self.member) && self.isLogged);
    
    self.member = !(self.member) ? [CCDataManager sharedManager].user.member : self.member;
    
    NSMutableArray *tempRows = [NSMutableArray array];
    //cell icon and text dictionary
    [tempRows addObject:@{@"icon":@"icon_topic", @"text":NSLocalizedString(@"Topics", nil)}];
    [tempRows addObject:@{@"icon":@"icon_reply", @"text":NSLocalizedString(@"Replies(setting)", nil)}];
    
    if (self.isLogged && self.isMyself) {
        [tempRows addObject:@{@"icon":@"icon_favorite", @"text":NSLocalizedString(@"Favorites", nil)}];
        [tempRows addObject:@{@"icon":@"icon_notification", @"text":NSLocalizedString(@"Notifications", nil)}];
    }
    
    self.userRelatedRows = [NSArray arrayWithArray:tempRows];
}

- (void)configureNavi{
    
    

    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_navi_menu"] imageWithTintColor:kWhiteColor] style:SCBarButtonItemStylePlain handler:^(id sender) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
        }];
    
    
//
//    self.sc_navigationItem.rightBarButtonItem = [[SCBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Setting", nil) style:SCBarButtonItemStylePlain handler:^(id sender) {
//        //TODO 更多设置
//    }];
    
    self.sc_navigationBar.backgroundColor = [UIColor clearColor];
    
    
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"icon_navi_menu"] style:UIBarButtonItemStylePlain handler:^(id sender) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
//    }];
//    
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    
    //[self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"profile_head_bg" ofType:@"png"]] forBarMetrics:UIBarMetricsDefault];
    
    //self.navigationController.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kClearNaviBarBackgroundColorNotification object:nil];
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

}

- (void)configureTableView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorColor = kSeparatorColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.tableHeaderView = [self configureTableHeaderView];
    
    self.tableView.contentInsetTop = 0;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
}

- (UIView *)configureTableHeaderView{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 180)];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, kScreenWidth, 200)];
    backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImage.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"profile_head_bg" ofType:@"png"]];
    
    [self.headerView addSubview:backgroundImage];
    
    //Avatar
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kAvatarMaskHeight/2.0-kAvatarHeight/2.0, kAvatarMaskHeight/2.0-kAvatarHeight/2.0, kAvatarHeight, kAvatarHeight)];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = kAvatarHeight/2.0;
    self.avatarImageView.layer.borderColor = kWhiteColor.CGColor;
    self.avatarImageView.layer.borderWidth = 1.5;
    if (self.member.memberAvatarLarge.length > 0) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    }else{
        self.avatarImageView.image = [UIImage imageNamed:@"default_avatar"];
    }
    
    
    self.avatarMaskView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2.0-kAvatarMaskHeight/2.0, 36.0, kAvatarMaskHeight, kAvatarMaskHeight)];
    self.avatarMaskView.backgroundColor = [UIColor clearColor];
    self.avatarMaskView.layer.cornerRadius = kAvatarMaskHeight/2.0;
    self.avatarMaskView.layer.borderColor = [UIColor colorWithWhite:1.000 alpha:0.360].CGColor;
    self.avatarMaskView.layer.borderWidth = 1.0;

    [self.avatarMaskView addSubview:self.avatarImageView];
    
    [self.headerView addSubview:self.avatarMaskView];
    
    
    if (self.member.memberUserName.length > 0 || self.member.memberName.length > 0) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2.0-100, kAvatarMaskHeight+36+10, 200.0, 30.0)];
        self.nameLabel.text = self.member.memberName.length > 0 ? self.member.memberName : self.member.memberUserName;

        self.nameLabel.textColor = kWhiteColor;
        self.nameLabel.font = [UIFont systemFontOfSize:18.0];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.headerView addSubview:self.nameLabel];
    }
    
    self.avatarButton = [[UIButton alloc] initWithFrame:self.avatarMaskView.frame];
    self.avatarButton.backgroundColor = [UIColor clearColor];
    [self.avatarButton bk_addEventHandler:^(id sender) {
        if (!self.isLogged) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.headerView addSubview:self.avatarButton];
    
    
    return self.headerView;
}

- (void)configureNotification{
    [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    }];
}

#pragma mark - TableView Delegate and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.userRelatedRows.count;
    }
    if (section == 1) {
        return self.isMyself ? 2:1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0;
    }
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CellIdentifier";
    CCSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CCSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return [self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
                
                break;
                
            case 1:
                
                break;
                
            case 2:
                
                break;
                
            case 3:
                [self pushNotificationListViewController];
                break;
                
            default:
                break;
        }
        
    }
    if (indexPath.section == 1 && self.isMyself) {
        switch (indexPath.row) {
            case 0:
                [self sendEmail];
                break;
                
            case 1:
                [self showMoreSettingVC];
                break;
                
            default:
                break;
        }
    }
    if (indexPath.section == 1 && !self.isMyself) {
        [self showMoreSettingVC];
    }
}


#pragma mark - Configure Cell

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSDictionary *cellInfo = self.userRelatedRows[indexPath.row];
        [cell.imageView setImage:[UIImage imageNamed:[cellInfo objectForKey:@"icon"]]];
        [cell.textLabel setText:[cellInfo objectForKey:@"text"]];
    }
    
    if (indexPath.section == 1 && self.isMyself) {
        switch (indexPath.row) {
            case 0:
                [cell.imageView setImage:[UIImage imageNamed:@"icon_feedback"]];
                [cell.textLabel setText:NSLocalizedString(@"Feedback", nil)];
                break;
            case 1:
                [cell.imageView setImage:[UIImage imageNamed:@"icon_setting"]];
                [cell.textLabel setText:NSLocalizedString(@"More Settings", nil)];
                break;
                
            default:
                break;
        }
    }
    if (indexPath.section == 1 && !self.isMyself) {
        [cell.imageView setImage:[UIImage imageNamed:@"icon_setting"]];
        [cell.textLabel setText:NSLocalizedString(@"Settings", nil)];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:0.208 green:0.212 blue:0.224 alpha:1.000];
    cell.backgroundColor = kCellHighlightedColor;
    
    return cell;
}

#pragma mark - Accessories

- (void)sendEmail
{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"CoCode iOS客户端 意见反馈"];
    [mc setToRecipients:[NSArray arrayWithObjects:@"wuxueqian2010@icloud.com", nil]];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *content = [NSString stringWithFormat:@"<感谢您的反馈意见,我们会认真听取并改进!>\n\n系统版本:%@\n程序版本:%@ build %@",osVersion,version,build];
    [mc setMessageBody:content isHTML:NO];
    [self presentViewController:mc animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *notice;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            notice = @"您取消了发送";
            break;
        case MFMailComposeResultSaved:
            notice = @"反馈已保存, 请记得发送";
            break;
        case MFMailComposeResultSent:
            notice = @":-) 邮件已发送, 感谢您的反馈";
            break;
        case MFMailComposeResultFailed:
            notice = [NSString stringWithFormat:@":-(发生了错误: %@",[error localizedDescription]];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^(void){
        [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.800]];
        [SVProgressHUD setForegroundColor:kWhiteColor];
        [SVProgressHUD showImage:nil status:notice];
    }];
}

- (void)showMoreSettingVC{
    CCSettingViewController *settingVC = [[CCSettingViewController alloc] init];
    
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)pushNotificationListViewController{
    CCNotificationListViewController *notificationListVC = [[CCNotificationListViewController alloc] init];
    [self.navigationController pushViewController:notificationListVC animated:YES];
}

@end
