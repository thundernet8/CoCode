//
//  SCNavigationItem.m
//  v2ex-iOS
//
//  Created by Singro on 5/25/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCNavigationItem.h"

@interface SCNavigationItem ()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, assign) UIViewController *_sc_viewController;

@end

@implementation SCNavigationItem

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTitle:(NSString *)title {
    
    _title = title;
    
    if (!title) {
        _titleLabel.text = @"";
        return;
    }
    
    if ([title isEqualToString:_titleLabel.text]) {
        return;
    }
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_titleLabel setTextColor:kNavigationBarTintColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [__sc_viewController.sc_navigationBar addSubview:_titleLabel];
    }
    
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    NSUInteger otherButtonWidth = self.leftBarButtonItem.view.width + self.rightBarButtonItem.view.width;
    _titleLabel.width = kScreenWidth - otherButtonWidth - 20;
    _titleLabel.centerY = 42;
    _titleLabel.centerX = kScreenWidth/2;
    
}

- (void)setLeftBarButtonItem:(SCBarButtonItem *)leftBarButtonItem {
    
    if (__sc_viewController) {
        [_leftBarButtonItem.view removeFromSuperview];
        leftBarButtonItem.view.x = 0;
        leftBarButtonItem.view.centerY = 42;
        [__sc_viewController.sc_navigationBar addSubview:leftBarButtonItem.view];
    }
    
    _leftBarButtonItem = leftBarButtonItem;
}

- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems{
    if (__sc_viewController) {
        NSInteger count = 0;
        for (SCBarButtonItem *barItem in leftBarButtonItems) {
            if (count > 2) {
                return;
            }
            barItem.view.x = count*40;
            barItem.view.centerY = 42;
            [__sc_viewController.sc_navigationBar addSubview:barItem.view];
            count++;
        }
    }
    
    _leftBarButtonItems = leftBarButtonItems;
}

- (void)setRightBarButtonItem:(SCBarButtonItem *)rightBarButtonItem {
    
    if (__sc_viewController) {
        [_rightBarButtonItem.view removeFromSuperview];
        rightBarButtonItem.view.x = kScreenWidth - rightBarButtonItem.view.width;
        rightBarButtonItem.view.centerY = 42;
        [__sc_viewController.sc_navigationBar addSubview:rightBarButtonItem.view];
    }
    
    _rightBarButtonItem = rightBarButtonItem;

}

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems{
    if (__sc_viewController) {
        NSInteger count = 0;
        rightBarButtonItems = [[rightBarButtonItems reverseObjectEnumerator] allObjects];
        for (SCBarButtonItem *barItem in rightBarButtonItems) {
            if (count > 2) {
                return;
            }
            barItem.view.x = kScreenWidth - 40*(count+1) - 10;
            barItem.view.centerY = 42;
            [__sc_viewController.sc_navigationBar addSubview:barItem.view];
            count++;
        }
    }
    
    _rightBarButtonItems = rightBarButtonItems;
}

#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    
    [_titleLabel setTextColor:kNavigationBarTintColor];
    
}

@end

