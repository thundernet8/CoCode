//
//  CCMyAccountViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/12/5.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMyAccountViewController.h"
#import "CCUserModel.h"
#import "CCDataManager.h"

@interface CCMyAccountViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSURLSessionDataTask * (^getCurrentUserProfileBlock)();
@property (nonatomic, strong) CCUserModel *user;

@end

@implementation CCMyAccountViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.user = [[CCDataManager sharedManager] user];
    }
    
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self configureNavi];
    [self configureTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNotification];
    [self configureBlocks];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.getCurrentUserProfileBlock();
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc");
}

#pragma mark - Setter

- (void)setUser:(CCUserModel *)user{
    _user = user;
    
    [self.tableView reloadData];
}

#pragma mark - Configuration

- (void)configureNavi{
    
    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationItem.title = NSLocalizedString(@"My account", nil);
    
}

- (void)configureTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.contentInsetTop = 44.0;
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = kSeparatorColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}

- (void)configureNotification{
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    }];
    
}

- (void)configureBlocks{
    
    @weakify(self);
    self.getCurrentUserProfileBlock = ^{
        return [[CCDataManager sharedManager] getCurrentUserDetailSuccess:^(CCUserModel *user) {
            @strongify(self);
            self.user = user;
        } failure:^(NSError *error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }];
    };
    
}

#pragma mark - TableView Delegate and Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    return [self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //TODO didselect
    
    [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_info"] withText:NSLocalizedString(@"Unavailable Now", nil)];
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"NickName", nil);
                cell.detailTextLabel.text = self.user.member.memberName;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Email", nil);
                cell.detailTextLabel.text = self.user.email;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            default:
                break;
        }
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Website", nil);
                cell.detailTextLabel.text = self.user.member.memberWebsite;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Website Name", nil);
                cell.detailTextLabel.text = self.user.member.memberWebsiteName;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            default:
                break;
        }
    }
    
    if (indexPath.section == 2) {
        cell.textLabel.text = NSLocalizedString(@"Change Password", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.textColor = kFontColorBlackDark;
    cell.detailTextLabel.textColor = kFontColorBlackLight;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.backgroundColor = kCellHighlightedColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
