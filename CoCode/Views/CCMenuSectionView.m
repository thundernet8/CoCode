//
//  CCMenuSectionView.m
//  CoCode
//
//  Created by wuxueqian on 15/11/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMenuSectionView.h"

#import "CCMenuSectionCell.h"

#import "CCLoginViewController.h"
#import "CoCodeAppDelegate.h"
#import "CCDataManager.h"

static CGFloat const kAvatarHeight = 68.0;

@interface CCMenuSectionView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UIImageView *divideImageView;
@property (nonatomic, strong) UILabel *usernameLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *sectionIconArray;
@property (nonatomic, strong) NSArray *sectionTitleArray;

@end

@implementation CCMenuSectionView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //self.sectionIconArray = @[@"icon_menu_newest", @"icon_menu_latest", @"icon_menu_hot", @"icon_menu_cat", @"icon_menu_tag", @"icon_menu_profile"];
        self.sectionIconArray = @[@"fa-clock-o", @"fa-calendar", @"fa-fire", @"fa-book", @"fa-tags", @"fa-user"];
        self.sectionTitleArray = @[NSLocalizedString(@"Recently Active", @"Recently replied,edited,new"), NSLocalizedString(@"Latest Publish", @"Latest published topics"), NSLocalizedString(@"Hot", @"Hot topics"), NSLocalizedString(@"Categories", @"Categories"), NSLocalizedString(@"Tags", @"Tags"), NSLocalizedString(@"Profile", @"Personal related")];
        
        //TODO configure
        [self configureTableView];
        [self configureProfileView];
        
        //Notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
        
    }
    return self;
}

#pragma mark - Life Cycle

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure Views

- (void)configureTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInsetTop = 120.0;
    [self addSubview:self.tableView];
}

- (void)configureProfileView{
    // Avatar
    self.avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_avatar"]];
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = kAvatarHeight/2.0;
    self.avatarView.layer.borderColor = RGB(0x8a8a8a, 1.0).CGColor;
    //self.avatarView.layer.borderWidth = 1.0;
    [self addSubview:self.avatarView];
    
    self.avatarView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    
    //TODO is logined
    
    //Tap to login
    self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.avatarButton bk_whenTapped:^{
        if (![CCDataManager sharedManager].user.isLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
        }else{
            //TODO 提示注销
            
        }
    }];
    [self addSubview:self.avatarButton];
}

#pragma mark - Layout

- (void)layoutSubviews{
    self.avatarView.frame = CGRectMake(80.0, 36.0, kAvatarHeight, kAvatarHeight);
    self.avatarButton.frame = self.avatarView.frame;
    
    self.divideImageView.frame = CGRectMake(-self.width, kAvatarHeight+50, self.width*2, 0.5);
    self.tableView.frame = CGRectMake(0.0, 0.0, self.width, self.height);
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kSetting.selectedSectionIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Setter

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    if (selectedIndex < self.sectionTitleArray.count) {
        _selectedIndex = selectedIndex;
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma makr - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = - scrollView.contentOffsetY;
    
    self.avatarView.y = 30 - (scrollView.contentInsetTop - offsetY) / 1.7;
    self.avatarButton.frame = self.avatarView.frame;
    
    self.divideImageView.y = self.avatarView.y + kAvatarHeight + (offsetY - (self.avatarView.y + kAvatarHeight)) / 2.0 + fabs(offsetY - self.tableView.contentInsetTop)/self.tableView.contentInsetTop * 8.0 + 10;
}

#pragma mark - TableView Delegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sectionTitleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self cellHeightForIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"MenuCell";
    CCMenuSectionCell *cell = (CCMenuSectionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[CCMenuSectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return [self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.didSelectedIndexBlock) {
        self.didSelectedIndexBlock(indexPath.row);
    }
}

#pragma mark - Configure Cell

- (CGFloat)cellHeightForIndexPath:(NSIndexPath *)indexPath{
    return [CCMenuSectionCell getCellHeight];
}

- (CCMenuSectionCell *)configureCell:(CCMenuSectionCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.iconName = self.sectionIconArray[indexPath.row];
    cell.title = self.sectionTitleArray[indexPath.row];
    cell.badge = nil;
    return cell;
}

#pragma mark - Notification

- (void)didReceiveThemeChangeNotification{
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kSetting.selectedSectionIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    self.avatarView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    self.divideImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
}









@end
