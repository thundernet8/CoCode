//
//  TopicViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/11/10.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "TopicViewController.h"
#import "CategoryViewController.h"
#import "CCDataManager.h"
#import "CCTopicTitleCell.h"
#import "CCTopicMetaCell.h"
#import "CCTopicBodyCell.h"
#import "CCTopicReplyCell.h"

#import "CCTopicPostModel.h"

@interface TopicViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SCBarButtonItem *leftBarItem;
@property (nonatomic, strong) SCBarButtonItem *rightBarItem;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UILabel *categoryNameLabel;

@property (nonatomic, strong) NSURLSessionDataTask * (^getTopicBlock)();

@property (nonatomic, copy) NSDictionary *topicCategory;

@property (nonatomic, strong) CCTopicPostModel *selectedReply;


@end

@implementation TopicViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    
    self.tableView.backgroundColor = kBackgroundColorWhite;
    
    self.hiddenEnabled = YES;
    
    self.tableView.contentInsetTop = 64 - 36;
    
}

#pragma mark - Setter

- (void)setTopic:(CCTopicModel *)topic{
    _topic = topic;
    
    BOOL isFirstSet = topic.posts.count > 0 ? NO : YES;
    
    //self.sc_navigationItem.title = topic.topicTitle;
    
    self.topicCategory = topic.topicCategory;
    self.categoryNameLabel.text = [self.topicCategory objectForKey:@"NAME"];
    
//    [self.tableView beginUpdates];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView endUpdates];
    if (!isFirstSet) {
        [self.tableView reloadData];
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
    
    SCBarButtonItem *bar1 = [[SCBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_heart_o"] imageWithTintColor:kColorPurple] style:SCBarButtonItemStylePlain handler:^(id sender) {
        NSLog(@"1");
    }];
    SCBarButtonItem *bar2 = [[SCBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_comment"] imageWithTintColor:kColorPurple] style:SCBarButtonItemStylePlain handler:^(id sender) {
        NSLog(@"2");
    }];
    SCBarButtonItem *bar3 = [[SCBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_nav_share"] imageWithTintColor:kColorPurple] style:SCBarButtonItemStylePlain handler:^(id sender) {
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
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)configureHeaderView{
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 36.0)];
    self.headerView.backgroundColor = kBackgroundColorWhiteDark;
    
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
        CategoryViewController *catViewController = [[CategoryViewController alloc] init];
        [self.navigationController pushViewController:catViewController animated:YES];
        
    } forControlEvents:UIControlEventTouchUpInside];
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
        @strongify(self);
        //self.getTopicBlock();
    };
    
}


#pragma mark - TableView Datasource and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }else{
        return self.topic.posts ? (self.topic.posts.count-1) : 0;
    }
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
                return [CCTopicBodyCell getCellHeightWithTopicModel:self.topic];
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
    
    static NSString *bodyCellIdentifier = @"bodyCellIdentifier";
    CCTopicBodyCell *bodyCell = [tableView dequeueReusableCellWithIdentifier:bodyCellIdentifier];
    if (!bodyCell) {
        bodyCell = [[CCTopicBodyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bodyCellIdentifier];
    }
    
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
                return [self configureBodyCell:bodyCell atIndexPath:indexPath];
                
            default:
                break;
        }
    }
    
    if (indexPath.section == 1) {
        return [self configureReplyCell:replyCell atIndexPath:indexPath];
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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

- (CCTopicReplyCell *)configureReplyCell:(CCTopicReplyCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    CCTopicPostModel *post = self.topic.posts[indexPath.row+1];
    cell.post = post;
    cell.replyToPost = self.selectedReply;
    cell.nav = self.navigationController;
    
    @weakify(self);
    cell.reloadCellBlock = ^{
        @strongify(self);
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    };
    
    return cell;
}












@end
