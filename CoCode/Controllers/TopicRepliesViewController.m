//
//  TopicRepliesViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/11/15.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "TopicRepliesViewController.h"
#import "CCTopicReplyCell.h"

@interface TopicRepliesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CCTopicPostModel *selectedReply;

@end

@implementation TopicRepliesViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuration

- (void)configureTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44.0, kScreenWidth, kScreenHeight-44.0) style:UITableViewStylePlain];
    
    self.tableView.backgroundColor = kBackgroundColorWhite;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.918 alpha:1.000];
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)configureNaviBar{
    @weakify(self);
    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_cancel"] imageWithTintColor:kBlackColor] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    self.sc_navigationItem.title = NSLocalizedString(@"Comments", nil);
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

#pragma mark - Tableview delegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count > 0 ? _posts.count-1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CCTopicPostModel *post = _posts[indexPath.row+1];

    return [CCTopicReplyCell getCellHeightWithPostModel:post];
}

- (CCTopicReplyCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"ReplyCell";
    CCTopicReplyCell *cell = (CCTopicReplyCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CCTopicReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return [self configureReplyCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}




@end
