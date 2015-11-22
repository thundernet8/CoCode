//
//  CCSettingManager.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCSettingManager.h"

#define kLineColorBlackDarkDefault    RGB(0xdbdbdb, 1.0)
#define kLineColorBlackLightDefault   RGB(0xebebeb, 1.0)

#define kFontColorBlackDarkDefault    RGB(0x333333, 1.0)
#define kFontColorBlackDarkMiddle     RGB(0x777777, 1.0)
#define kFontColorBlackLightDefault   RGB(0x999999, 1.0)
#define kFontColorBlackBlueDefault    RGB(0x778087, 1.0)
#define kColorBlueDefault             RGB(0x3fb7fc, 1.0)
#define kColorPurpleDefault           RGB(0x6b6ee6, 1.0)

#define kCellHighlightColor           RGB(0xdbdbdb, 0.6)
#define kMenuCellHighlightColor       RGB(0xf6f6f6, 1.0)

static NSString *const kTheme           = @"Theme";
static NSString *const kThemeAutoChange = @"ThemeAutoChange";
static NSString *const kNonePicsMode = @"NonePicsMode";

static NSString *const kSelectedSectionIndex = @"SelectedSectionIndex";

@interface CCSettingManager()

@end

@implementation CCSettingManager

- (instancetype)init{
    if (self = [super init]) {
        self.selectedSectionIndex = [[kUserDefaults objectForKey:kSelectedSectionIndex] unsignedIntegerValue];
        //TODO
        
        _theme = [[kUserDefaults objectForKey:kTheme] integerValue];
        id themeAutoChange = [kUserDefaults objectForKey:kThemeAutoChange];
        if (themeAutoChange) {
            _themeAutoChange = [themeAutoChange boolValue];
        }else{
            _themeAutoChange = YES;
        }
        
        [self configureTheme:_theme];
    }
    return self;
}

+ (instancetype)sharedManager{
    static CCSettingManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CCSettingManager alloc] init];
    });
    return manager;
}

#pragma mark - Selection Index

- (void)setSelectedSectionIndex:(NSUInteger)selectedSectionIndex{
    _selectedSectionIndex = selectedSectionIndex;
    
    [kUserDefaults setObject:@(selectedSectionIndex) forKey:kSelectedSectionIndex];
    [kUserDefaults synchronize];
}

#pragma mark - Theme

- (void)setTheme:(CCTheme)theme{
    _theme = theme;
    
    [kUserDefaults setObject:@(theme) forKey:kTheme];
    [kUserDefaults synchronize];
    
    [self configureTheme:theme];
    
    //Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kThemeDidChangeNotification object:nil];
}

- (void)configureTheme:(CCTheme)theme{
    if (theme == CCThemeNight) {
        //Navigation Color
        self.navigationBarTintColor = RGB(0xcccccc, 1.0);
        self.navigationBarColor = [UIColor colorWithWhite:0.000 alpha:0.980];
        self.navigationBarLineColor = [UIColor colorWithWhite:0.281 alpha:1.000];
        
        //Background Color
        self.backgroundColorWhite = kBlackColor;
        self.backgroundColorWhiteDark = [UIColor colorWithWhite:0.10 alpha:1.0];
        
        //Line Color
        self.lineColorBlackDark = [UIColor colorWithWhite:0.28 alpha:1.0];
        self.lineColorBlackLight = [UIColor colorWithWhite:0.12 alpha:1.0];
        
        //Font Color
        self.fontColorBlackDark = RGB(0x989898, 1.0);
        self.fontColorBlackMid = RGB(0x777777, 1.0);
        self.fontColorBlackLight = [UIColor colorWithWhite:0.28 alpha:1.0];
        self.fontColorBlackBlue = RGB(0x778087, 1.0);
        
        //Color
        self.colorPurple = [UIColor colorWithWhite:1.0 alpha:0.1];
        self.cellHighlightedColor = RGB(0x333333, 1.0);
        self.menuCellHighlightedColor = [UIColor colorWithWhite:0.12 alpha:1.0];
        
        //Notification
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }else{
        //Navigation Color
        self.navigationBarTintColor = kBlackColor;
        self.navigationBarColor = [UIColor colorWithWhite:0.973 alpha:0.980];
        self.navigationBarLineColor = [UIColor colorWithWhite:0.88 alpha:1.0];
        
        //Background Color
        self.backgroundColorWhite = kWhiteColor;
        self.backgroundColorWhiteDark = [UIColor colorWithRed:0.941 green:0.945 blue:0.961 alpha:1.000];
        
        //Line Color
        self.lineColorBlackDark = kLineColorBlackDarkDefault;
        self.lineColorBlackLight = kLineColorBlackLightDefault;
        
        //Font Color
        self.fontColorBlackDark = kFontColorBlackDarkDefault;
        self.fontColorBlackMid  = kFontColorBlackDarkMiddle;
        self.fontColorBlackLight = kFontColorBlackLightDefault;
        self.fontColorBlackBlue = kFontColorBlackBlueDefault;
        
        //Color
        self.colorPurple = kColorPurpleDefault;
        self.cellHighlightedColor = kCellHighlightColor;
        self.menuCellHighlightedColor = kMenuCellHighlightColor;
        
        //Status Bar
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        
    }
}

- (void)setThemeAutoChange:(BOOL)themeAutoChange{
    _themeAutoChange = themeAutoChange;
    
    [kUserDefaults setObject:@(themeAutoChange) forKey:kThemeAutoChange];
    [kUserDefaults synchronize];
}

- (void)setNonePicsMode:(BOOL)nonePicsMode{
    _nonePicsMode = nonePicsMode;
    
    [kUserDefaults setObject:@(nonePicsMode) forKey:kNonePicsMode];
    [kUserDefaults synchronize];
}

//Image Alpha
- (CGFloat)imageViewAlphaForCurrentTheme {
    if (kCurrentTheme == CCThemeNight) {
        return 0.4;
    } else {
        return 1.0;
    }
}







@end