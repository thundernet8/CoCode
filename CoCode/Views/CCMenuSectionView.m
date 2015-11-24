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

@interface CCMenuSectionView()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UIView *divideView;
@property (nonatomic, strong) UILabel *usernameLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *sectionIconArray;
@property (nonatomic, strong) NSArray *sectionTitleArray;

@end

@implementation CCMenuSectionView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.sectionIconArray = @[@"icon_menu_newest", @"icon_menu_latest", @"icon_menu_hot", @"icon_menu_cat",  @"icon_menu_profile"];
        //self.sectionIconArray = @[@"fa-clock-o", @"fa-calendar", @"fa-fire", @"fa-book",  @"fa-user"]; //@"fa-tags",
        self.sectionTitleArray = @[NSLocalizedString(@"Recently Active", @"Recently replied,edited,new"), NSLocalizedString(@"Latest Publish", @"Latest published topics"), NSLocalizedString(@"Hot", @"Hot topics"), NSLocalizedString(@"Categories", @"Categories"),  NSLocalizedString(@"Profile", @"Personal related")]; //NSLocalizedString(@"Tags", @"Tags"),
        
        //TODO configure
        [self configureTableView];
        [self configureProfileView];
        
        //Notification
        [self configureNotification];
        
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
    
    self.tableView.scrollEnabled = NO;
    
    [self addSubview:self.tableView];
}

- (void)configureProfileView{
    // Avatar
    self.avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_avatar"]];
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = kAvatarHeight/2.0;
    self.avatarView.layer.borderColor = RGB(0xaaaaaa, 0.2).CGColor;
    self.avatarView.layer.borderWidth = 1.0;
    [self addSubview:self.avatarView];
    
    self.avatarView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    
    self.usernameLabel = [[UILabel alloc] init];
    [self addSubview:self.usernameLabel];
    self.usernameLabel.font = [UIFont systemFontOfSize:16.0];
    self.usernameLabel.alpha = 0;
    
    //TODO is logined
    if ([CCDataManager sharedManager].user.isLogin) {
        self.usernameLabel.text = [kUserDefaults objectForKey:kUsername];
        self.usernameLabel.alpha = 1;
        
        [self.avatarView sd_setImageWithURL:[kUserDefaults objectForKey:kAvatarURL] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    }
    
    //Tap to login
    self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.avatarButton bk_whenTapped:^{
        
        if (![CCDataManager sharedManager].user.isLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
            
        }else{
            
            [self showLogoutActionSheetView];
            
        }
    }];
    [self addSubview:self.avatarButton];
    
    self.divideView = [[UIView alloc] init];
    self.divideView.backgroundColor = kLineColorBlackLight;
    [self addSubview:self.divideView];
}

- (void)configureNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
//        CCUserModel *user = note.object;
//        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:user.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self configureProfileWithLoginSuccessNotification];
        });
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLogoutSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self configureProfileWithLogoutSuccessNotification];
    }];
}

- (void)configureProfileWithLoginSuccessNotification{
    if ([CCDataManager sharedManager].user.isLogin) {
        [self.avatarView sd_setImageWithURL:[kUserDefaults objectForKey:kAvatarURL] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
        [UIImageView animateWithDuration:0.8 animations:^{
            self.avatarView.frame = CGRectMake(35.0, 45.0, 50.0, 50.0);
        } completion:^(BOOL finished) {
            self.usernameLabel.text = [kUserDefaults objectForKey:kUsername];
            self.usernameLabel.alpha = 1;
        }];
    }
}

- (void)configureProfileWithLogoutSuccessNotification{
    if (![CCDataManager sharedManager].user.isLogin) {
        self.usernameLabel.text = @"";
        self.usernameLabel.alpha = 0;
        self.avatarView.layer.cornerRadius = kAvatarHeight/2.0;
        [self.avatarView setImage:[UIImage imageNamed:@"default_avatar"]];
        [UIImageView animateWithDuration:0.8 animations:^{
            self.avatarView.frame = CGRectMake(80.0, 36.0, kAvatarHeight, kAvatarHeight);
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - Layout

- (void)layoutSubviews{
    self.avatarView.frame = CGRectMake(80.0, 36.0, kAvatarHeight, kAvatarHeight);
    self.avatarButton.frame = CGRectMake(35.0, 36.0, 160.0, kAvatarHeight);
    if ([CCDataManager sharedManager].user.isLogin) {
        self.usernameLabel.frame = CGRectMake(100.0, 36, 100.0, kAvatarHeight);
        self.avatarView.layer.cornerRadius = 25;
        self.avatarView.x -= 45;
        self.avatarView.width = 50;
        self.avatarView.height = 50;
        self.avatarView.centerY = 36+kAvatarHeight/2.0;
    }
    
    self.divideView.frame = CGRectMake(0, kAvatarHeight+50, self.width, 1.0);
    self.tableView.frame = CGRectMake(0.0, 20.0, self.width, self.height);
    
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
    
    self.divideView.y = self.avatarView.y + kAvatarHeight + (offsetY - (self.avatarView.y + kAvatarHeight)) / 2.0 + fabs(offsetY - self.tableView.contentInsetTop)/self.tableView.contentInsetTop * 8.0 + 10;
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
    self.divideView.backgroundColor = kLineColorBlackLight;
    self.avatarView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    self.divideView.alpha = kSetting.imageViewAlphaForCurrentTheme;
}

#pragma mark - ActionSheet

- (void)showLogoutActionSheetView{
    if ([CCDataManager sharedManager].user.isLogin) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Sure to logout?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Logout", nil) otherButtonTitles:nil];
        [sheet showInView:AppDelegate.window];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [[CCDataManager sharedManager] userLogout];
    }
}





@end
