//
//  CategoryViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/11/11.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCCategoryViewController.h"
#import "CCDataManager.h"
#import "CCTopicListCell.h"
#import "CCTopicViewController.h"
#import "CCCategoryModel.h"
#import "CCFilterViewController.h"
#import "CoCodeAppDelegate.h"

@interface CCCategoryViewController () <UITableViewDelegate, UITableViewDataSource>

//Current Page
@property (nonatomic, assign) NSInteger pageCount;

@property (nonatomic, strong) NSURL *categoryUrl;
@property (nonatomic, assign) NSInteger catID;

@property (nonatomic, strong) NSArray *filters;

//Get topics block
@property (nonatomic, copy) NSURLSessionDataTask *(^getTopicListBlock)(NSInteger);

@property (nonatomic, strong) CCTopicList *topicList;

@property (nonatomic) BOOL isFirstLoad;

@end

@implementation CCCategoryViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pageCount = 1;
        self.isFirstLoad = YES;
        NSDictionary *categories = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"]];
        NSMutableArray *tempFilters = [NSMutableArray array];
        for (NSString *key in categories) {
            NSDictionary *dict = @{@"ID":[[categories objectForKey:key] objectForKey:@"ID"], @"TEXT":[[categories objectForKey:key] objectForKey:@"NAME"]};
            [tempFilters addObject:dict];
        }
        self.filters = [NSArray arrayWithArray:tempFilters];
    }
    
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self configureCategory];
    
    [self configureNavi];
    [self configureTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureBlocks];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
}

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
    if (self.isFirstLoad) {
        @strongify(self);
        [self beginRefresh];
    }
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

#pragma mark - Configuration

- (void)configureCategory{
    if (!self.cat) {
        NSNumber *lastSelectedCatID = [kUserDefaults objectForKey:@"lastSelectedCatID"];
        NSArray *availableCatIDs = @[@3,@5,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17];
        if (![availableCatIDs containsObject:lastSelectedCatID]) {
            lastSelectedCatID = @3;
        }
        self.cat = [[CCCategoryModel alloc] initWithDict:[CCHelper getCategoryInfoFromPlistForID:lastSelectedCatID]];
    }
    self.catID = self.cat.ID.integerValue;
}

- (void)configureNavi{
    if (self.navigationController.viewControllers.count > 1) {
        self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }else{
        self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_navi_menu"] style:SCBarButtonItemStylePlain handler:^(id sender) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
        }];
    }
    
    self.sc_navigationItem.rightBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_filter"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        [self presentFiltersViewController];
    }];;
    
    self.sc_navigationItem.title = self.cat.name;
}

- (void)configureTableView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.contentInsetTop = 44.0;
    
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorColor = kSeparatorColor;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)configureBlocks{
    
    @weakify(self);
    self.getTopicListBlock = ^(NSInteger page){
        @strongify(self);
        
        self.pageCount = page;
        self.isFirstLoad = NO;
        
        return [[CCDataManager sharedManager] getTopicListWithPage:page categoryUrl:self.categoryUrl success:^(CCTopicList *list) {
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
        self.getTopicListBlock(1);
    };
}

#pragma mark - Setter

- (void)setCat:(CCCategoryModel *)cat{
    _cat = cat;
    _categoryUrl = cat.url;
    _catID = cat.ID.integerValue;
    self.sc_navigationItem.title = cat.name;
}

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
    
    cell.inCategory = YES;
    cell.topic = topic;
    
    
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
        NSLog(@"%@", filter.description);
        if ([[filter objectForKey:@"ID"] integerValue] != self.catID) {
            [rootController dismissViewControllerAnimated:YES completion:nil];
            self.catID = [[filter objectForKey:@"ID"] integerValue];
            self.cat = [[CCCategoryModel alloc] initWithDict:[CCHelper getCategoryInfoFromPlistForID:[NSNumber numberWithInteger:self.catID]]];
            [kUserDefaults setObject:[NSNumber numberWithInteger:self.catID] forKey:@"lastSelectedCatID"];
            [self beginRefresh];
        }else{
            [rootController dismissViewControllerAnimated:YES completion:nil];
        }
        
    };

    filterViewController.filters = self.filters;
    filterViewController.tag = self.catID;
    filterViewController.filterTitle = NSLocalizedString(@"Select Category", nil);
    
    //Present filter view modaly
    filterViewController.modalPresentationStyle = UIModalPresentationPopover;
    filterViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    SCNavigationController *navVC = [[SCNavigationController alloc] initWithRootViewController:filterViewController];
    
    [rootController presentViewController:navVC animated:YES completion:^{
        
    }];
}

#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
}


@end
