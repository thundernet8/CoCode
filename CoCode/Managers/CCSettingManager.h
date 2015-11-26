//
//  CCSettingManager.h
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

typedef NS_ENUM(NSInteger, CCTheme) {
    CCThemeDefault,
    CCThemeNight,
};

@interface CCSettingManager : NSObject

+ (instancetype)sharedManager;

#pragma mark - Index

@property (nonatomic, assign) NSUInteger selectedSectionIndex;

#pragma mark - Theme

@property (nonatomic, assign) CCTheme theme;
@property (nonatomic, assign) BOOL themeAutoChange;
@property (nonatomic, assign) BOOL nonePicsMode;

@property (nonatomic, copy) UIColor *backgroundColorWhite;
@property (nonatomic, copy) UIColor *backgroundColorWhiteDark;

@property (nonatomic, copy) UIColor *navigationBarColor;
@property (nonatomic, copy) UIColor *navigationBarLineColor;
@property (nonatomic, copy) UIColor *navigationBarTintColor;

@property (nonatomic, copy) UIColor *lineColorBlackDark;
@property (nonatomic, copy) UIColor *lineColorBlackLight;

@property (nonatomic, copy) UIColor *fontColorBlackDark;
@property (nonatomic, copy) UIColor *fontColorBlackMid;
@property (nonatomic, copy) UIColor *fontColorBlackLight;
@property (nonatomic, copy) UIColor *fontColorBlackBlue;

@property (nonatomic, copy) UIColor *colorPurple;
@property (nonatomic, copy) UIColor *cellHighlightedColor;
@property (nonatomic, copy) UIColor *menuCellHighlightedColor;

@property (nonatomic, assign) CGFloat imageViewAlphaForCurrentTheme;

@property (nonatomic, assign) UIStatusBarStyle currentStatusBarStyle;
@property (nonatomic, copy) UIColor *separatorColor;

@property (nonatomic, copy) UIColor *menuIconColor;

@end
