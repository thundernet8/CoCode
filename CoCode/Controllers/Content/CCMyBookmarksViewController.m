//
//  CCMyBookmarksViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/12/5.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMyBookmarksViewController.h"

#import "CCDataManager.h"
#import "CCUserBookmarkListCell.h"
#import "CCTopicViewController.h"

@interface CCMyBookmarksViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSURLSessionDataTask * (^getBookmarksBlock)(NSInteger);
@property (nonatomic, assign) NSInteger pageCount;

@property (nonatomic, strong) CCUserBookmarksModel *userBookmarksModel;

@end

@implementation CCMyBookmarksViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pageCount = 1;
        self.userBookmarksModel = [[CCUserBookmarksModel alloc] init];
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
    
    [self configureNotifications];
    [self configureBlocks];
    
    [self beginRefresh];
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
    NSLog(@"dealloc");
}

#pragma mark - Setter

- (void)setUserBookmarksModel:(CCUserBookmarksModel *)userBookmarksModel{
    if (self.userBookmarksModel.list.count > 0 && self.pageCount !=1) {
        NSMutableArray *tempList = [[NSMutableArray alloc] initWithArray:self.userBookmarksModel.list];
        [tempList addObjectsFromArray:userBookmarksModel.list];
        userBookmarksModel.list = tempList;
    }
    _userBookmarksModel = userBookmarksModel;
    
    [self.tableView reloadData];
}

#pragma mark - Configuration

- (void)configureNavi{
    
    self.sc_navigationItem.title = NSLocalizedString(@"Bookmarks", nil);
    @weakify(self);
    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}

- (void)configureNotifications{
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    }];
    
}

- (void)configureTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.contentInsetTop = 44.0;
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}

- (void)configureBlocks{
    
    @weakify(self);
    self.getBookmarksBlock = ^(NSInteger page){
        @strongify(self);
        self.pageCount = page;
        return [[CCDataManager sharedManager] getMyBookmarksWithPage:page success:^(CCUserBookmarksModel *model) {
            
            self.userBookmarksModel = model;
            if (self.pageCount > 1) {
                [self endLoadMore];
            }else{
                [self endRefresh];
                if (model.list.count >= 60) {
                    self.loadMoreBlock = ^{
                        @strongify(self);
                        self.pageCount ++;
                        
                        self.getBookmarksBlock(self.pageCount);
                    };
                }else{
                    self.loadMoreBlock = nil;
                }
            }
        } failure:^(NSError *error) {
            @strongify(self);
            if (self.pageCount > 1) {
                if (error.code >= 900) {
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
        self.getBookmarksBlock(1);
    };
}

#pragma mark - TableView Delegate and Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.userBookmarksModel.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self getCellHeightAtIndexPath:indexPath];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"UserBookmarkCell";
    CCUserBookmarkListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CCUserBookmarkListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return [self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CCTopicModel *topic = self.userBookmarksModel.list[indexPath.row];;
    CCTopicViewController *topicVC = [[CCTopicViewController alloc] init];
    topicVC.topic = topic;
    [self.navigationController pushViewController:topicVC animated:YES];
}

- (CCUserBookmarkListCell *)configureCell:(CCUserBookmarkListCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.topic = self.userBookmarksModel.list[indexPath.row];
    return cell;
}

- (CGFloat)getCellHeightAtIndexPath:(NSIndexPath *)indexPath{
    
    CCTopicModel *topic = self.userBookmarksModel.list[indexPath.row];
    return [CCUserBookmarkListCell getCellHeightWithTopicModel:topic];
    
}


@end
