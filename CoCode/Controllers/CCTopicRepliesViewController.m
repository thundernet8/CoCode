//
//  TopicRepliesViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/11/15.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicRepliesViewController.h"
#import "CCTopicReplyCell.h"

#import "CCDataManager.h"

@interface CCTopicRepliesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CCTopicPostModel *selectedReply;

@property (nonatomic, strong) NSCache *cellHeightCache;

@property (nonatomic, copy) NSURLSessionDataTask *(^getReplyListBlock)(NSInteger page);

@property (nonatomic, strong) NSArray *replyStream;

@property (nonatomic) NSInteger pageCount;

@property (nonatomic, strong) NSArray *replyList;

@end

@implementation CCTopicRepliesViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.pageCount = 1;
        self.cellHeightCache = [[NSCache alloc] init];
    }
    
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self configureTableView];
    [self configureNaviBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureBlocks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.replyStream) {
        [self beginRefresh];
    }
}

- (void)dealloc{
    NSLog(@"dealloc");
}

#pragma mark - Setter

- (void)setTopic:(CCTopicModel *)topic{
    _topic = topic;
    
    self.replyStream = self.topic.replyStream;
}

- (void)setReplyList:(NSArray *)replyList{
    
    if (_replyList) {
        replyList = [_replyList arrayByAddingObjectsFromArray:replyList];
    }
    _replyList = replyList;
    
    [self.tableView reloadData];
}

#pragma mark - Configuration

- (void)configureTableView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.contentInsetTop = 44.0;
    
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)configureNaviBar{
    @weakify(self);
    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_back"] imageWithTintColor:kBlackColor] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationItem.title = NSLocalizedString(@"Comments", nil);
}

- (void)configureBlocks{
    
    @weakify(self);
    
    self.getReplyListBlock = ^(NSInteger page){
        
        @strongify(self);
        
        self.pageCount = page;
        
        return [[CCDataManager sharedManager] getTopicReplyListWithTopicID:[self.topic.topicID integerValue] inPage:page replyStream:self.replyStream success:^(NSArray *replyList) {
            
            self.replyList = replyList;
            
            if (self.pageCount > 1) {
                [self endLoadMore];
            }else{
                [self endRefresh];
                if (replyList.count >= 20) {
                    self.loadMoreBlock = ^{
                        @strongify(self);
                        self.pageCount ++;
                        
                        self.getReplyListBlock(self.pageCount);
                    };
                }
            }
            
        } failure:^(NSError *error) {
            @strongify(self);
            if (self.pageCount > 1) {
                [self endLoadMore];
                if (error.code >= 900) {
                    //Reached the end, no more topics
                    [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_info"] withText:NSLocalizedString(@"No more replies", nil)];
                }
            }else{
                [self endRefresh];
            }
        }];
        
    };
    
    self.refreshBlock = ^{
        @strongify(self);
        
        self.getReplyListBlock(1);
    };
}

- (CCTopicReplyCell *)configureReplyCell:(CCTopicReplyCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    CCTopicPostModel *post = self.replyList[indexPath.row];
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

#pragma mark - Tableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.replyList.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    
    CGFloat cellHeight = [[self.cellHeightCache objectForKey:key] floatValue];
    
    if (!cellHeight) {
        CCTopicReplyCell *cell = [self tableView:tableView prepareCellForRowAtIndexPath:indexPath];
        cellHeight = [cell getCellHeight];
    }
    
    return cellHeight;
}

- (CCTopicReplyCell *)tableView:(UITableView *)tableView prepareCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"ReplyCell";
    
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    

    CCTopicReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CCTopicReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell = [self configureReplyCell:cell atIndexPath:indexPath];
        [self.cellHeightCache setObject:[NSNumber numberWithFloat:cell.cellHeight] forKey:key];
    }else{
       cell = [self configureReplyCell:cell atIndexPath:indexPath];
    }
    
 
    return cell;
    
}

- (CCTopicReplyCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self tableView:tableView prepareCellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //TODO reply's action
}




@end
