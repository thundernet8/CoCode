//
//  CCPlatformIcon.h
//  CoCode
//
//  Created by wuxueqian on 15/12/8.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCSharePublicHeader.h"

@interface CCPlatformIcon : UIView

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) void (^buttonBlock)();

- (instancetype)initWithPlatformInfoDict:(NSDictionary *)dict;

@end
