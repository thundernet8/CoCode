//
//  CCNotificationListViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/11/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCNotificationListViewController.h"

#import "CCNotificationListModel.h"
#import "CCNotificationListCell.h"
#import "CCMessageModel.h"
#import "CCBadgeModel.h"
#import "CCDataManager.h"
#import "CCMessageTopicViewController.h"

@interface CCNotificationListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSInteger pageCount; // Default 60 per pages
@property (nonatomic, strong) NSString *username;

@property (nonatomic, copy) NSURLSessionDataTask *(^getNotificationListBlock)(NSInteger, NSString *);

@property (nonatomic, copy) CCNotificationListModel *notificationList;

@end

@implementation CCNotificationListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.pageCount = 1;
        self.username = [CCDataManager sharedManager].user.member.memberUserName;
    }
    
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self configureNavi];
    [self configureTableview];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNotification];//TODO OK
    [self configureBlocks];//TODO OK
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = kStatusBarStyle;

    //weakify and strongify is from ReactiveCocoa(EXTScope)
    //@weakify(self);
    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
        //@strongify(self);
        [self beginRefresh];
    //});

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.hiddenEnabled = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSLog(@"disappear %d", (int)CFGetRetainCount((__bridge CFTypeRef)(self)));
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"dealloc");
}

#pragma mark - Configuration

- (void)configureNavi{
    
    @weakify(self);
    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationItem.title = NSLocalizedString(@"Notifications", nil);
}

- (void)configureTableview{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)configureNotification{
    
    @weakify(self);
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        @strongify(self);
        
        self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    }];
}

- (void)configureBlocks{
    @weakify(self);
    
    self.getNotificationListBlock = ^(NSInteger page, NSString *username){
        @strongify(self);
        
        return [[CCDataManager sharedManager] getNotificationListWithPage:page username:username success:^(CCNotificationListModel *notificationList) {
            
            self.notificationList = notificationList;
            
            if (self.pageCount > 1) {
                [self endLoadMore];
            }else{
                [self endRefresh];
                if (notificationList.list.count >= 60) {
                    @strongify(self);
                    self.pageCount++;
                    
                    self.getNotificationListBlock(self.pageCount, self.username);
                }else{
                    self.loadMoreBlock = nil;
                }
            }
            
        } failure:^(NSError *error) {
            @strongify(self);
            if (self.pageCount > 1) {
                if (error.code > 900) {
                    //Reached the end, no more topics
                    [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_info"] withText:NSLocalizedString(@"No more topics", @"Cannot loadmore topics, reached the end")];
                }
                [self endLoadMore];
            }else{
                [self endRefresh];
            }
        }];
    };
    
    self.refreshBlock = ^{
        @strongify(self);
        self.getNotificationListBlock(1, self.username);
    };
}

#pragma mark - Setter

- (void)setNotificationList:(CCNotificationListModel *)notificationList{
    
    if (self.notificationList.list > 0 && self.pageCount != 1) {
        NSMutableArray *list = [[NSMutableArray alloc] initWithArray:self.notificationList.list];
        
        [list addObjectsFromArray:notificationList.list];
        
        notificationList.list = list;
        notificationList.totalCount += self.notificationList.totalCount;
    }
    
    _notificationList = notificationList;
    
    [self.tableView reloadData];
}

#pragma mark - Tableview Delegate and Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notificationList.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id notificationModel = self.notificationList.list[indexPath.row];
    
    CCNotificationType type = [notificationModel isKindOfClass:[CCMessageModel class]] ? CCNotificationTypeMessage : CCNotificationTypeBadge;
    
    return [CCNotificationListCell getCellHeightWithNotificationType:type];
}

- (CCNotificationListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"NotificationListCell";
    CCNotificationListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CCNotificationListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];;
    }
    
    
    return [self configureCell:cell atIndexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id model = self.notificationList.list[indexPath.row];
    
    if ([model isKindOfClass:[CCMessageModel class]]) {
        CCMessageTopicViewController *messagesVC = [[CCMessageTopicViewController alloc] init];
        CCMessageModel *messageModel = (CCMessageModel *)model;
        messagesVC.messageTopicID = messageModel.topicID;
        messagesVC.senderName = messageModel.fromUserDisplayName.length >0 ? messageModel.fromUserDisplayName : messageModel.fromUsername;
        
        [self.navigationController pushViewController:messagesVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Configure Cell

- (CCNotificationListCell *)configureCell:(CCNotificationListCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    id model = self.notificationList.list[indexPath.row];
    
    return [cell configureWithNotificationModel:model];
}

@end
