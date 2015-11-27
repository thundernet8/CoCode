//
//  TopicViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/11/10.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicViewController.h"
#import "CCCategoryViewController.h"
#import "CCDataManager.h"
#import "CCTopicTitleCell.h"
#import "CCTopicMetaCell.h"
#import "CCTopicBodyCell.h"
#import "CCTopicReplyCell.h"

#import "CCTopicPostModel.h"
#import "CCCategoryModel.h"
#import "CCTopicRepliesViewController.h"

#import "CoCodeAppDelegate.h"

@interface CCTopicViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SCBarButtonItem *leftBarItem;
@property (nonatomic, strong) SCBarButtonItem *rightBarItem;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UILabel *categoryNameLabel;

@property (nonatomic, strong) NSURLSessionDataTask * (^getTopicBlock)();

@property (nonatomic, strong) CCCategoryModel *topicCategory;

@property (nonatomic, strong) CCTopicPostModel *selectedReply;

@property (nonatomic, assign) BOOL isDragging;

@property (nonatomic, strong) NSCache *cellCache;

@end

@implementation CCTopicViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cellCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self configureBarItems];
    [self configureTableView];
    [self configureHeaderView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNaviBar];
    
    [self configureNotifications];
    
    [self configureBlocks];
    
    if (!self.topic.posts) {
        self.getTopicBlock();
    }
    
    //TODO
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [UIApplication sharedApplication].statusBarStyle = kStatusBarStyle;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.topic.posts || self.topic.posts.count == 0) {
        @weakify(self);
        [self bk_performBlock:^(id obj) {
            @strongify(self);
            [self beginLoadMore];
        } afterDelay:0.0];
    }
}

- (void)dealloc{
    
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.hiddenEnabled = YES;
    
    self.tableView.contentInsetTop = 64 - 36;
    
}

#pragma mark - Setter

- (void)setTopic:(CCTopicModel *)topic{
    _topic = topic;
    
    BOOL isFirstSet = topic.posts.count > 0 ? NO : YES;
    
    //self.sc_navigationItem.title = topic.topicTitle;
    
    self.topicCategory = (CCCategoryModel *)topic.topicCategory;
    self.categoryNameLabel.text = self.topicCategory.name;
    
    
//    [self.tableView beginUpdates];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView endUpdates];
    if (!isFirstSet) {
        //[self.tableView reloadData];
        NSIndexPath *metaIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        NSIndexPath *bodyIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[metaIndexPath, bodyIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];

    }
}

#pragma mark - Configuration

- (void)configureBarItems{
    @weakify(self);
    self.leftBarItem = [[SCBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_back"] imageWithTintColor:kBlackColor] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    //TODO 右导航按钮 分享功能
}

- (void)configureNaviBar{
    self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
    
    @weakify(self);
    
    SCBarButtonItem *bar1 = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_heart_o"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        NSLog(@"1");
    }];
    SCBarButtonItem *bar2 = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_comment"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        CCTopicRepliesViewController *repliesVC = [[CCTopicRepliesViewController alloc] init];
        @strongify(self);
        
        repliesVC.posts = self.topic.posts;
        repliesVC.topic = self.topic;
        SCNavigationController *navController = [[SCNavigationController alloc] initWithRootViewController:repliesVC];
        [AppDelegate.window.rootViewController presentViewController:navController animated:YES completion:^{
            
        }];
    }];
    SCBarButtonItem *bar3 = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_nav_share2"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        
        @strongify(self);
        
        NSLog(@"3");
    }];
    self.sc_navigationItem.rightBarButtonItems = @[bar1, bar2, bar3];
    //self.sc_navigationItem.rightBarButtonItems = @[self.leftBarItem, self.leftBarItem];
    //self.sc_navigationItem.title = self.topic ? self.topic.topicTitle : NSLocalizedString(@"Topic", nil);
    //self.sc_navigationItem.titleLabel.font = [UIFont systemFontOfSize:14.0];
    //self.sc_navigationItem.titleLabel.frame = CGRectMake(45.0, 32.0, kScreenWidth-90.0, 20.0);
}

- (void)configureTableView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = kBackgroundColorWhite;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)configureHeaderView{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 36.0)];
    self.headerView.backgroundColor = kBackgroundColorGray;
    
    self.categoryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 200.0, 36.0)];
    self.categoryNameLabel.textColor = kFontColorBlackLight;
    self.categoryNameLabel.font = [UIFont systemFontOfSize:15.0];
    self.categoryNameLabel.userInteractionEnabled = NO;
    [self.headerView addSubview:self.categoryNameLabel];
    
    UIImageView *rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_arrow"]];
    rightArrowImageView.userInteractionEnabled = NO;
    rightArrowImageView.frame = CGRectMake(0.0, 13.0, 5.0, 10.0);
    rightArrowImageView.x = kScreenWidth - 15.0;
    [self.headerView addSubview:rightArrowImageView];
    
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headerButton.frame = CGRectMake(0.0, 0.0, self.headerView.width, self.headerView.height);
    [self.headerView addSubview:headerButton];
    
    self.tableView.tableHeaderView = self.headerView;
    
    //Handles
    @weakify(self);
    [headerButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        CCCategoryViewController *catViewController = [[CCCategoryViewController alloc] init];
        catViewController.cat = self.topicCategory;
        [self.navigationController pushViewController:catViewController animated:YES];
        
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureNotifications{
    
    @weakify(self);
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        @strongify(self);
        self.headerView.backgroundColor = kBackgroundColorGray;
        self.categoryNameLabel.textColor = kFontColorBlackLight;
        self.tableView.backgroundColor = kBackgroundColorWhite;
    }];
}

- (void)configureBlocks{
    
    @weakify(self);
    self.getTopicBlock = ^{
        @strongify(self);
        
        return [[CCDataManager sharedManager] getTopicWithTopicID:self.topic.topicID.integerValue success:^(CCTopicModel *topic) {
            
            self.topic = topic;
            
            if ([self isLoadingMore]) {
                self.loadMoreBlock = nil;
                [self endLoadMore];
            }
            
        } failure:^(NSError *error) {
            if ([self isLoadingMore]) {
                self.loadMoreBlock = nil;
                [self endLoadMore];
            }
        }];
    };
    
    self.loadMoreBlock = ^{
        //@strongify(self);
        //self.getTopicBlock();
    };
    
}


#pragma mark - TableView Datasource and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return 40;
                break;
            case 1:
                return 28;
                break;
            case 2:
                return 0;
                break;
                
            default:
                break;
        }
    }else if (indexPath.section == 1){
        return 0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return [CCTopicTitleCell getCellHeightWithTopicModel:self.topic];
                break;
            case 1:
                return [CCTopicMetaCell getCellHeightWithTopicModel:self.topic];
                break;
            case 2:
                //return [CCTopicBodyCell getCellHeightWithTopicModel:self.topic];
                return [self getCellHeightForTableView:tableView atIndexPath:indexPath];
                break;
                
            default:
                break;
        }
    }
    if (indexPath.section == 1) {
        CCTopicPostModel *post = self.topic.posts[indexPath.row + 1];
        return [CCTopicReplyCell getCellHeightWithPostModel:post];
    }
    return 0;
}

- (CCTopicBodyCell *)tableView:(UITableView *)tableView prepareCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *bodyCellIdentifier = @"bodyCellIdentifier";
    
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    
    CCTopicBodyCell *cell = [self.cellCache objectForKey:key];
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:bodyCellIdentifier];
        if (!cell) {
            cell = [[CCTopicBodyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bodyCellIdentifier];
        }
    }
    
    return [self configureBodyCell:cell atIndexPath:indexPath];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *titleCellIdentifier = @"titleCellIdentifier";
    CCTopicTitleCell *titleCell = [tableView dequeueReusableCellWithIdentifier:titleCellIdentifier];
    if (!titleCell) {
        titleCell = [[CCTopicTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:titleCellIdentifier];
    }
    
    static NSString *metaCellIdentifier = @"metaCellIdentifier";
    CCTopicMetaCell *metaCell = [tableView dequeueReusableCellWithIdentifier:metaCellIdentifier];
    if (!metaCell) {
        metaCell = [[CCTopicMetaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:metaCellIdentifier];
    }
    
    CCTopicBodyCell *bodyCell = [self tableView:tableView prepareCellForRowAtIndexPath:indexPath];
    
    static NSString *replyCellIdentifier = @"replyCellIdentifier";
    CCTopicReplyCell *replyCell = [tableView dequeueReusableCellWithIdentifier:replyCellIdentifier];
    if (!replyCell) {
        replyCell = [[CCTopicReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:replyCellIdentifier];
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return [self configureTitleCell:titleCell atIndexPath:indexPath];
                break;
            case 1:
                return [self configureMetaCell:metaCell atIndexPath:indexPath];
                break;
            case 2:
                return bodyCell;
                
            default:
                break;
        }
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Configure TableView Cell

- (CCTopicTitleCell *)configureTitleCell:(CCTopicTitleCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.topic = self.topic;
    cell.nav = self.navigationController;
    return cell;
}

- (CCTopicMetaCell *)configureMetaCell:(CCTopicMetaCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.topic = self.topic;
    cell.nav = self.navigationController;
    @weakify(self);
    cell.reloadCellBlcok = ^{
        @strongify(self);
        
        NSLog(@"wo");
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    };
    
    return cell;
}

- (CCTopicBodyCell *)configureBodyCell:(CCTopicBodyCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.topic = self.topic;
    cell.nav = self.navigationController;
    @weakify(self);
    cell.reloadCellBlcok = ^{
        @strongify(self);
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    };
    
    return cell;
}


#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    
    self.isDragging = YES;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    if (scrollView.contentOffsetY < - 64 + 36) {
        self.isDragging = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.contentInsetTop = 64;
        } completion:^(BOOL finished) {
            if (!decelerate) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.tableView.contentInsetTop = 64 - 36;
                }];
            }
        }];
    } else {
        self.isDragging = NO;
        self.tableView.contentInsetTop = 64 - 36;
    }
    
}



- (CGFloat)getCellHeightForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    CCTopicBodyCell *cell = [self tableView:tableView prepareCellForRowAtIndexPath:indexPath];
    
    return [cell getCellHeight];
}







@end
