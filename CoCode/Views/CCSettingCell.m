//
//  CCSwitchButtonCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/22.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCSettingCell.h"

@interface CCSettingCell()

@property (nonatomic ,strong) UIView *separatorLine;

@end

@implementation CCSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-68.0, 10.0, 50.0, 30.0)];
        self.switchButton.alpha = 0;
        [self addSubview:self.switchButton];
        
        self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, 0.0, 80.0, 50.0)];
        [self addSubview:self.rightLabel];
        
        self.centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2.0-40, 0.0, 80.0, 50.0)];
        self.centerLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.centerLabel];
        
        self.separatorLine = [[UIView alloc] init];
        self.separatorLine.backgroundColor = kSeparatorColor;
        [self addSubview:self.separatorLine];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            self.backgroundColor = kCellHighlightedColor;
            self.separatorLine.backgroundColor = kSeparatorColor;
        }];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.separatorLine.frame = CGRectMake(10.0, 50.0, kScreenWidth-10, 0.5);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
