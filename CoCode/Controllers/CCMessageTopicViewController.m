//
//  CCMessageTopicViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/11/24.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMessageTopicViewController.h"

#import "CCMessageTopicModel.h"
#import "CCMessagePostCell.h"
#import "CCDataManager.h"
#import "CCMemberProfileViewController.h"

@interface CCMessageTopicViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic) NSInteger pageCount;
//@property (nonatomic, copy) CCMessageTopicModel *messageTopic;
@property (nonatomic, copy) CCMessageTopicPostsModel *messagePosts;
@property (nonatomic, strong) CCMemberModel *sender;
@property (nonatomic, strong) NSCache *cellCache;
@property (nonatomic) unsigned long previousTimestamp;
@property (nonatomic, strong) NSNumber *previousPostID;
@property (nonatomic, copy) NSURLSessionDataTask * (^getMessagePostsBlock)(NSInteger, NSNumber *);

@end

@implementation CCMessageTopicViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isForceLoadMoreView = YES;
        self.previousTimestamp = 0;
        self.previousPostID = @0;
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
    
    [self configureBlocks];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self beginLoadMore];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"dealloc");
}

#pragma mark - Setter

- (void)setMessagePosts:(CCMessageTopicPostsModel *)messagePosts{
    
    if (self.messagePosts.lists.count > 0 && self.pageCount > 1) {
        NSArray *posts = [messagePosts.lists arrayByAddingObjectsFromArray:_messagePosts.lists];
        
        messagePosts.lists = posts;
    }
    
    _messagePosts = messagePosts;
    
    [self.tableView reloadData];
}

- (void)setSender:(CCMemberModel *)sender{
    _sender = sender;
    
    self.sc_navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - Configuration

- (void)configureNavi{
    
    self.sc_navigationItem.title = self.senderName;
    
    @weakify(self);
    
    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationItem.rightBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_profile"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        CCMemberProfileViewController *memberProfileVC = [[CCMemberProfileViewController alloc] init];
        memberProfileVC.member = self.sender;
        
        if (self.sender) {
            [self.navigationController pushViewController:memberProfileVC animated:YES];
        }
        
    }];
    
    self.sc_navigationItem.rightBarButtonItem.enabled = NO;
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
    
    self.getMessagePostsBlock = ^(NSInteger page, NSNumber *topicID){
      
        @strongify(self);
        
        self.pageCount = page;
        
        return [[CCDataManager sharedManager] getMessageTopicPostsWithPage:page topicID:topicID success:^(CCMessageTopicPostsModel *messageTopicPosts, CCMemberModel *sender) {
            
            self.messagePosts = messageTopicPosts;
            self.sender = sender;
            
            if (self.pageCount > 1) {
                [self endRefresh];
            }else{
                [self endLoadMore];
                if (messageTopicPosts.lists.count >= 20) {
                    self.refreshBlock = ^{
                        @strongify(self);
                        self.pageCount++;
                        self.getMessagePostsBlock(self.pageCount, self.messageTopicID);
                    };
                }
            }
            
        } failure:^(NSError *error) {
            @strongify(self);
            if (self.pageCount > 1) {
                if (error.code >= 900) {
                    //Reached the end, no more topics
                    [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_info"] withText:NSLocalizedString(@"No more topics", @"Cannot loadmore topics, reached the end")];
                }
                [self endRefresh];
            }else{
                [self endLoadMore];
            }
        }];
        
    };
    
    self.loadMoreBlock = ^{
        @strongify(self);
        self.getMessagePostsBlock(1, self.messageTopicID);
    };
}

#pragma mark - Tableview Delegate and Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messagePosts.lists.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    CCMessagePostCell *cell = [self tableView:tableView prepareCellForRowAtIndexPath:indexPath];
    
    return [cell getCellHeight];
}

- (CCMessagePostCell *)tableView:(UITableView *)tableView prepareCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"MessagePostCell";
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    CCMessagePostCell *cell = [self.cellCache objectForKey:key];
    
    if (!cell) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[CCMessagePostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        CCTopicPostModel *post = self.messagePosts.lists[indexPath.row];
        
        BOOL needTimeLabel;
        if (![post.postID isEqualToNumber:self.previousPostID]) {
            unsigned long postTimestamp = [post.postCreatedTime timeIntervalSince1970];
            needTimeLabel = self.previousTimestamp - postTimestamp > 60;
            self.previousPostID = post.postID;
            self.previousTimestamp = postTimestamp;
        }
        cell.needTimeLabel = needTimeLabel;
        cell.nav = self.navigationController;
        cell = [cell configureWithMessagePost:post];
        
        [self.cellCache setObject:cell forKey:key];
        
    }
    
    return cell;
}

- (CCMessagePostCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return [self tableView:tableView prepareCellForRowAtIndexPath:indexPath];
    
//    static NSString *identifier = @"MessagePostCell";
//    
//    CCMessagePostCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    
//    if (!cell) {
//        cell = [[CCMessagePostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
//    
//    return [self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Scrollview Delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    CGFloat loadMoreOffset = scrollView.contentSizeHeight - self.view.height - scrollView.contentOffsetY + scrollView.contentInsetBottom;
    
    //NSLog(@"%f\n%f\n%f\n%f", scrollView.contentSizeHeight, self.view.height, scrollView.contentOffsetY, scrollView.contentInsetBottom); //TODO clear
    if (loadMoreOffset < -60 && self.loadMoreBlock && !self.isLoadingMore && scrollView.contentSizeHeight > 0 && scrollView.contentOffsetY > 0) {
        
        [self beginLoadMore];
    }
}

@end
