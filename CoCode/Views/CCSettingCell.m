//
//  CCSwitchButtonCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/22.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCSettingCell.h"

@implementation CCSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-68.0, 10.0, 50.0, 30.0)];
        self.switchButton.alpha = 0;
        [self addSubview:self.switchButton];
        
        self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, 0.0, 80.0, 50.0)];
        [self addSubview:self.rightLabel];
    }
    
    return self;
}

@end
