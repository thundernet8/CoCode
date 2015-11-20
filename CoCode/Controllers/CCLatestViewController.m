//
//  CCLatestTopicsViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCLatestViewController.h"
#import <NSString+FontAwesome.h>
#import "UIImage+Tint.h"
#import "CCDataManager.h"
#import "CCHelper.h"
#import "CCTopicListCell.h"
#import "CCMemberModel.h"
#import "CCTopicViewController.h"

@interface CCLatestViewController ()<UITableViewDelegate,UITableViewDataSource>

//Current Page
@property (nonatomic, assign) NSInteger pageCount;

//Left Navibar Item
@property (nonatomic, strong) SCBarButtonItem *leftBarItem;

//Get topics block
@property (nonatomic, copy) NSURLSessionDataTask *(^getTopicListBlock)(NSInteger);

@property (nonatomic, strong) CCTopicList *topicList;

@end

@implementation CCLatestViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pageCount = 1;
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self configureTableView];
    [self configureNavibarItems];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureBlocks];
    
    self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationItem.title = NSLocalizedString(@"Latest Publish", @"Latest published topics");
    
    //TODO Notification
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        [self beginRefresh];
    }];
    
}

#pragma mark - Life Cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //weakify and strongify is from ReactiveCocoa(EXTScope)
    @weakify(self);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @strongify(self);
        [self beginRefresh];
    });
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.hiddenEnabled = YES;
}

#pragma mark - Configure

- (void)configureNavibarItems{
    self.leftBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_navi_menu"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
    }];
}

- (void)configureTableView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)configureBlocks{
    
    @weakify(self);
    self.getTopicListBlock = ^(NSInteger page){
        @strongify(self);
        
        if (![CCDataManager sharedManager].user.isLogin) {
            
            if (self.isRefreshing) {
                [self endRefresh];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
            
            return [NSURLSessionDataTask new];
        }
        
        self.pageCount = page;
        
        return [[CCDataManager sharedManager] getTopicListLatestWithPage:page success:^(CCTopicList *list) {
            @strongify(self);
            
            self.topicList = list;
            
            if (self.pageCount > 1) {
                [self endLoadMore];
            }else{
                [self endRefresh];
                if (list.list.count >= 30) {
                    self.loadMoreBlock = ^{
                        @strongify(self);
                        self.pageCount ++;
                        
                        self.getTopicListBlock(self.pageCount);
                    };
                }
            }
            
        } failure:^(NSError *error) {
            @strongify(self);
            if (self.pageCount > 1) {
                if (error.code == 104) {
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
        self.getTopicListBlock(1);
    };
}

#pragma mark - Setter

- (void)setTopicList:(CCTopicList *)topicList{
    if (self.topicList.list.count > 0 && self.pageCount != 1) {
        NSMutableArray *list = [[NSMutableArray alloc] initWithArray:self.topicList.list];
        NSMutableDictionary *posters = [[NSMutableDictionary alloc] initWithDictionary:self.topicList.posters];
        [list addObjectsFromArray:topicList.list];
        [posters addEntriesFromDictionary:topicList.posters];
        topicList.list = list;
        topicList.posters = posters;
    }
    _topicList = topicList;
    
    [self.tableView reloadData];
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.topicList.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightOfTopicCellForIndexPath:indexPath];
}

#pragma mark - TableView Delegate

- (CCTopicListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    CCTopicListCell *cell = (CCTopicListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[CCTopicListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    CCTopicModel *topic = self.topicList.list[indexPath.row];
    CCMemberModel *author = [self.topicList.posters objectForKey:[NSString stringWithFormat:@"ID%d", (int)topic.topicAuthorID]];
    topic.topicAuthorAvatar = author.memberAvatarLarge;
    topic.topicAuthorName = author.memberName;
    
    cell.topic = topic;
    cell.inCategory = NO;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CCTopicViewController *topicViewController = [[CCTopicViewController alloc] init];
    CCTopicModel *topic = self.topicList.list[indexPath.row];
    CCMemberModel *author = [self.topicList.posters objectForKey:[NSString stringWithFormat:@"ID%d", (int)topic.topicAuthorID]];
    topic.topicAuthorAvatar = author.memberAvatarLarge;
    topic.topicAuthorName = author.memberName;
    topicViewController.topic = topic;
    [self.navigationController pushViewController:topicViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}


#pragma mark - Configure Cell

- (CGFloat)heightOfTopicCellForIndexPath:(NSIndexPath *)indexPath{
    CCTopicModel *topic = self.topicList.list[indexPath.row];
    return [CCTopicListCell getCellHeightWithTopicModel:topic];
}


#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
}




@end
