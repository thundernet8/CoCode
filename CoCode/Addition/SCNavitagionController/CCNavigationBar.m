//
//  CCNavigationBar.m
//  CoCode
//
//  Created by wuxueqian on 15/11/2.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCNavigationBar.h"

@interface CCNavigationBar()

@property (nonatomic, strong) UIView *lineView;

@end

@implementation CCNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = (CGRect){0, 0, kScreenWidth, 64};
        
        self.backgroundColor = kNavigationBarColor;
        
        self.lineView = [[UIView alloc] initWithFrame:(CGRect){0, 64, kScreenWidth, 0.5}];
        self.lineView.backgroundColor = kNavigationBarLineColor;
        [self addSubview:self.lineView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
        
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    
    self.backgroundColor = kNavigationBarColor;
    self.lineView.backgroundColor = kNavigationBarLineColor;
}

@end
