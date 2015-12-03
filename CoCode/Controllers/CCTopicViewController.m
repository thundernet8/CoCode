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
#import "CCTopicViewToolBar.h"
#import "CCTopicViewReplyInput.h"

#import "CCTopicPostModel.h"
#import "CCCategoryModel.h"
#import "CCTopicRepliesViewController.h"

#import "CoCodeAppDelegate.h"

@interface CCTopicViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UILabel *categoryNameLabel;

@property (nonatomic, strong) CCTopicViewToolBar *footerToolBar;
@property (nonatomic, strong) CCTopicViewReplyInput *replyInput;

@property (nonatomic, strong) NSURLSessionDataTask * (^getTopicBlock)();

@property (nonatomic, strong) CCCategoryModel *topicCategory;

@property (nonatomic, strong) CCTopicPostModel *selectedReply;

@property (nonatomic, assign) BOOL isLoaded;

@property (nonatomic, assign) BOOL isDragging;

@end

@implementation CCTopicViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isLoaded = NO;
        
    }
    return self;
}

- (void)loadView{
    [super loadView];

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self configureToolBar];
    //[self configureReplyInputView];
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
    NSLog(@"dealloc");
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.hiddenEnabled = YES;
    
    self.tableView.contentInsetTop = 64 - 36;
    
}

#pragma mark - Setter

- (void)setTopic:(CCTopicModel *)topic{

    BOOL needUpdateNavi = _topic && (_topic.isLiked^topic.isLiked);
    
    _topic = topic;
    
    if (needUpdateNavi) {
        [self configureNaviBar];
    }
    
    BOOL isFirstSet = topic.posts.count > 0 ? NO : YES;
    
    self.topicCategory = (CCCategoryModel *)topic.topicCategory;
    self.categoryNameLabel.text = self.topicCategory.name;
    
    
    if (!isFirstSet) {
        //[self.tableView reloadData];
        NSIndexPath *metaIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        NSIndexPath *bodyIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[metaIndexPath, bodyIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];

    }
}

#pragma mark - Configuration

- (void)configureNaviBar{
    
    @weakify(self);
    
    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_back"] imageWithTintColor:kBlackColor] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];;
    
    NSString *heartIconName = self.topic.isLiked ? @"icon_heart" : @"icon_heart_o";
    
    SCBarButtonItem *bar1 = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:heartIconName] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self likeActivity];
    }];
    SCBarButtonItem *bar2 = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_star"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self bookmarkPost];
    }];
    SCBarButtonItem *bar3 = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_nav_share2"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        
        @strongify(self);
        
        [self shareActivity];
    }];
    self.sc_navigationItem.rightBarButtonItems = @[bar1, bar2, bar3];
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

- (void)configureToolBar{
    self.footerToolBar = [[CCTopicViewToolBar alloc] initWithFrame:CGRectMake(0, kScreenHeight-45, kScreenWidth, 45.0)];
    self.footerToolBar.model = self.topic;
    @weakify(self);
    self.footerToolBar.showCommentsActionBlock = ^{
        @strongify(self);
        [self showComments];
    };
    self.footerToolBar.showCommentEditorActionBlock = ^{
        @strongify(self);
        [self configureReplyInputView];
        [self.replyInput showView];
    };
    [self.view addSubview:self.footerToolBar];
}

- (void)configureReplyInputView{
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    self.replyInput = [[CCTopicViewReplyInput alloc] initWithFrame:mainWindow.bounds];
    self.replyInput.model = self.topic;
    @weakify(self);
    self.replyInput.dismissViewBlock = ^{
        @strongify(self);
        [self.replyInput removeFromSuperview];
        self.replyInput = nil;
    };
    [mainWindow addSubview:self.replyInput];
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
            
            self.isLoaded = YES;
            
            if ([self isLoadingMore]) {
                [self endLoadMore];
                self.loadMoreBlock = nil;
            }
        } failure:^(NSError *error) {
            
            if ([self isLoadingMore]) {
                [self endLoadMore];
                self.loadMoreBlock = nil;
            }
            
            [self handleLoadingFailure];
        }];
    };
    
    self.loadMoreBlock = ^{
//        
//        @strongify(self);
//        self.getTopicBlock();
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

    return 0;
}

- (CCTopicBodyCell *)tableView:(UITableView *)tableView prepareCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *bodyCellIdentifier = @"bodyCellIdentifier";
    
    CCTopicBodyCell *cell = [tableView dequeueReusableCellWithIdentifier:bodyCellIdentifier];
    if (!cell) {
        cell = [[CCTopicBodyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bodyCellIdentifier];
    }
        
    cell = [self configureBodyCell:cell atIndexPath:indexPath];

    return cell;
    
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



#pragma mark - Utilities

- (void)likeActivity{
    
    if (!_isLoaded) {
        return;
    }
    
    if (![CCDataManager sharedManager].user.isLogin) {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Need Login", nil) message:NSLocalizedString(@"You need login to vote this topic", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@[NSLocalizedString(@"Login", nil)] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
            }
        }];
        
        [alert show];
    }else if (self.topic.isLiked){
        [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_info"] withText:NSLocalizedString(@"Do not like it again", nil)];
    }else{
        
        
        if (self.topic.postID) {
            [[CCDataManager sharedManager] actionForPost:[self.topic.postID integerValue] actionType:CCPostActionTypeVote success:^(CCTopicPostModel *postModel) {
                
                self.topic.isLiked = YES;
                
                [self configureNaviBar];
                [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Liked", nil)];
                
            } failure:^(NSError *error) {
                
                [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_error"] withText:NSLocalizedString(@"Vote Failed", nil)];
                NSLog(@"%@", error.description);
            }];
        }
        
    }
}

- (void)bookmarkPost{
    if (!_isLoaded) {
        return;
    }
    
    if (![CCDataManager sharedManager].user.isLogin) {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Need Login", nil) message:NSLocalizedString(@"You need login to collect this topic", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@[NSLocalizedString(@"Login", nil)] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
            }
        }];
        
        [alert show];
    }else if (self.topic.isBookmarked){
        [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_info"] withText:NSLocalizedString(@"Do not bookmark it again", nil)];
    }else{
        
        if (self.topic.postID) {
            
            @weakify(self);
            [[CCDataManager sharedManager] bookmarkTopic:[self.topic.topicID integerValue] success:^(BOOL collectStatus) {
                @strongify(self);
                self.topic.isBookmarked = YES;
                
                [self configureNaviBar];
                [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Bookmarked", nil)];
            } failure:^(NSError *error) {
                [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_error"] withText:NSLocalizedString(@"Bookmark Failed", nil)];
                NSLog(@"%@", error.description);
            }];
            
        }
        
    }
    
}

- (void)showComments{
    
    if (!_isLoaded) {
        return;
    }
    
    CCTopicRepliesViewController *repliesVC = [[CCTopicRepliesViewController alloc] init];
    repliesVC.topic = self.topic;
    
    
    [self.navigationController pushViewController:repliesVC animated:YES];
    
//    SCNavigationController *navController = [[SCNavigationController alloc] initWithRootViewController:repliesVC];
//    [AppDelegate.window.rootViewController presentViewController:navController animated:YES completion:^{
//        
//    }];
}

- (void)shareActivity{
    
    if (!_isLoaded) {
        return;
    }
    
    //UIActivityViewController
    NSString *textToShare = self.topic.topicTitle;
    NSURL *urlToShare = self.topic.topicUrl;
    NSArray *activityItems = @[textToShare, urlToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    UIActivityViewControllerCompletionWithItemsHandler block = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
    {
        NSLog(@"activityType :%@", activityType);
        if (completed)
        {
            [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Share Article Successfully", nil)];
            NSLog(@"completed");
        }
        else
        {
            NSLog(@"cancel");
        }
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    };
    
    activityVC.completionWithItemsHandler = block;
    
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
    
}

//Error handle

- (void)handleLoadingFailure{
    [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_info"] withText:NSLocalizedString(@"Load topic failure, please try again", nil)];
}


@end
