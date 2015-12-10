//
//  PopTableViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/11/9.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCFilterViewController.h"

@interface CCFilterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SCBarButtonItem *cancelButton;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CCFilterViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)loadView{
    [super loadView];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.contentInsetTop = 44.0;
    
    [self.view addSubview:self.tableView];
    
    @weakify(self);
    
    self.cancelButton = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_cancel"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self configureNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"filterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    return [self configureCell:cell atIndexPath:indexPath];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.tag = [[self.filters[indexPath.row] objectForKey:@"ID"] integerValue];
    [self.tableView reloadData];
    
    if (self.onItemSelected) {
        self.onItemSelected(_filters[indexPath.row]);
    }
}

#pragma mark - Configuration

- (void)configureTableView{
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorColor = kLineColorBlackLight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)configureNavigationBar{
    
    self.sc_navigationItem.title = self.filterTitle ? self.filterTitle : NSLocalizedString(@"Filters", @"Hot topics period filters");
    self.sc_navigationItem.leftBarButtonItem = self.cancelButton;
    
    @weakify(self);
    self.cancelButton = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_cancel_black"]  style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *filter = (NSDictionary *)self.filters[indexPath.row];
    cell.textLabel.text = [filter objectForKey:@"TEXT"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (self.tag == [[self.filters[indexPath.row] objectForKey:@"ID"] integerValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

@end
