//
//  CCHotViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCHotViewController.h"
#import "UIImage+Tint.h"
#import "CCDataManager.h"
#import "CCTopicListCell.h"
#import "CCMemberModel.h"
#import "CCFilterViewController.h"
#import "CoCodeAppDelegate.h"
#import "CCTopicViewController.h"

@interface CCHotViewController ()<UITableViewDelegate,UITableViewDataSource>

//Current Page
@property (nonatomic, assign) NSInteger pageCount;

//Period Type
@property (nonatomic, assign) NSInteger period;

//Navibar Items
@property (nonatomic, strong) SCBarButtonItem *leftBarItem;
@property (nonatomic, strong) SCBarButtonItem *rightBarItem;

//Get topics block
@property (nonatomic, copy) NSURLSessionDataTask *(^getTopicListBlock)(NSInteger, NSInteger);

@property (nonatomic, strong) CCTopicList *topicList;

@end

@implementation CCHotViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pageCount = 1;
        self.period = 0;
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
    self.sc_navigationItem.rightBarButtonItem = self.rightBarItem;
    self.sc_navigationItem.title = NSLocalizedString(@"Hot", @"Hot");
    
    //TODO Notification
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    
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
    
    [UIApplication sharedApplication].statusBarStyle = kStatusBarStyle;
    
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
    self.rightBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_filter"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        [self presentFiltersViewController];
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
    self.getTopicListBlock = ^(NSInteger page, NSInteger period){
        @strongify(self);
        
        self.pageCount = page;
        self.period = period;
        
        return [[CCDataManager sharedManager] getTopicListHotWithPage:page inPeriod:period success:^(CCTopicList *list) {
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
                        
                        self.getTopicListBlock(self.pageCount, self.period);
                    };
                }else{
                    self.loadMoreBlock = nil;
                }
            }
            
        } failure:^(NSError *error) {
            @strongify(self);
            if (self.pageCount > 1) {
                if (error.code == 904) {
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
        self.getTopicListBlock(1, self.period);
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

- (void)setPeriod:(NSInteger)period{
    _period = period;
    //TODO 刷新页面 或者用 delegate
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
    CCMemberModel *author = [self.topicList.posters objectForKey:[NSString stringWithFormat:@"ID%d", topic.topicAuthorID.intValue]];
    topic.topicAuthorAvatar = author.memberAvatarLarge;
    topic.topicAuthorName = author.memberName;
    
    cell.topic = topic;
    cell.inCategory = NO;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CCTopicViewController *topicViewController = [[CCTopicViewController alloc] init];
    CCTopicModel *topic = self.topicList.list[indexPath.row];
    CCMemberModel *author = [self.topicList.posters objectForKey:[NSString stringWithFormat:@"ID%d", topic.topicAuthorID.intValue]];
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

#pragma mark - Handle filters VC

- (void)presentFiltersViewController{
    CoCodeAppDelegate *cocodeDelegate = [UIApplication sharedApplication].delegate;
    UIViewController *rootController = cocodeDelegate.window.rootViewController;
    
    CCFilterViewController *filterViewController = [[CCFilterViewController alloc] init];
    filterViewController.onItemSelected = ^(NSDictionary *filter){
        if ([[filter objectForKey:@"ID"] integerValue] != self.period) {
            [rootController dismissViewControllerAnimated:YES completion:nil];
            self.period = [[filter objectForKey:@"ID"] integerValue];
            [self beginRefresh];
        }else{
            [rootController dismissViewControllerAnimated:YES completion:nil];
        }
        
    };
    filterViewController.filters = @[@{@"ID":@0,@"TEXT":@"不限时间"},@{@"ID":@1,@"TEXT":@"今天"},@{@"ID":@2,@"TEXT":@"一周内"},@{@"ID":@3,@"TEXT":@"一月内"},@{@"ID":@4,@"TEXT":@"季度内"},@{@"ID":@5,@"TEXT":@"近一年"}];
    filterViewController.tag = self.period;
    
    //Present filter view modaly
    filterViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    filterViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    SCNavigationController *navVC = [[SCNavigationController alloc] initWithRootViewController:filterViewController];
    
    [rootController presentViewController:navVC animated:YES completion:^{
        
    }];
}


#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
}

@end
