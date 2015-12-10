//
//  CCSocialShareSheet.m
//  CoCode
//
//  Created by wuxueqian on 15/12/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCSocialShareSheet.h"
#import "CCPlatformIcon.h"
#import "CCShareManager.h"

static CGFloat const kContainerHeight = 168.0;

@interface CCSocialShareSheet()

@property (nonatomic, strong) UIView *backgroundMaskView;
@property (nonatomic, strong) UIButton *backgroundMaskButton;
#ifdef __IPHONE_8_0
@property (nonatomic, strong) UIVisualEffectView *blurContainerView;
#else
@property (nonatomic, strong) UIView *blurContainerView;
#endif
@property (nonatomic, strong) UIScrollView *scrollArea;

@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation CCSocialShareSheet

+ (CCSocialShareSheet *)sharedInstance{
    
    static CCSocialShareSheet *shareInstance = nil;
    static dispatch_once_t onceToken;
    @weakify(self);
    dispatch_once(&onceToken, ^{
        @strongify(self);
        shareInstance = [[self alloc] init];
    });
    
    return shareInstance;
}

- (void)showShareSheetWithPlatforms:(NSArray *)platforms{
    
    self.backgroundMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.backgroundMaskView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.100];
    [[UIApplication sharedApplication].keyWindow addSubview:self.backgroundMaskView];
    
    self.backgroundMaskButton = [[UIButton alloc] initWithFrame:self.backgroundMaskView.frame];
    @weakify(self);
    [self.backgroundMaskButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self dismissShareSheet];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundMaskView addSubview:self.backgroundMaskButton];
    
    UIView *contentView;
#ifdef __IPHONE_8_0
    self.blurContainerView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    self.blurContainerView.alpha = 1;
    contentView = self.blurContainerView.contentView;
#else
    self.blurContainerView = [[UIView alloc] init];
    self.blurContainerView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.200];
    contentView = self.blurContainerView;
#endif
    self.blurContainerView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kContainerHeight);
    [self.backgroundMaskView addSubview:self.blurContainerView];
    
    self.scrollArea = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 16.0, kScreenWidth, 100)];
    self.scrollArea.showsHorizontalScrollIndicator = NO;
    [contentView addSubview:self.scrollArea];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(16.0, kContainerHeight-54, kScreenWidth-32, 40)];
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.cancelButton.layer.cornerRadius = 5.0;
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.cancelButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self dismissShareSheet];
    } forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:self.cancelButton];
    
    //social icons
    for (int i = 0; i < platforms.count; i++) {
        CCPlatformIcon *icon = [[CCPlatformIcon alloc] initWithPlatformInfoDict:(NSDictionary *)platforms[i]];
        icon.frame = CGRectMake(10.0+80*i, 0, 60.0, 96.0);
        [self.scrollArea addSubview:icon];
        self.scrollArea.contentSize = CGSizeMake((i+1)*80.0, 96.0);
        
        //icon button event //TODO
        @weakify(icon);
        icon.buttonBlock = ^{
            @strongify(icon)
            [self shareActionWithPlatform:icon.button.tag];
        };
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self);
        self.blurContainerView.frame = CGRectMake(0, kScreenHeight-kContainerHeight-5, kScreenWidth, kContainerHeight+5);
    } completion:^(BOOL finished) {
        @strongify(self);
        [UIView animateWithDuration:0.2 animations:^{
            self.blurContainerView.frame = CGRectMake(0, kScreenHeight-kContainerHeight, kScreenWidth, kContainerHeight);
        }];
    }];
    
}

- (void)dismissShareSheet{
    
    self.backgroundMaskView.backgroundColor = [UIColor clearColor];
    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^{
        @strongify(self);
        self.backgroundMaskView.frame = CGRectMake(0, kScreenHeight-kContainerHeight, kScreenWidth, kScreenHeight);
    } completion:^(BOOL finished) {
        @strongify(self);
        [self.backgroundMaskView removeFromSuperview];
    }];
    
}

- (void)shareActionWithPlatform:(CCSharePlatform)platform{
    
    [self.delegate sharedToPlatform:platform];
}

@end
