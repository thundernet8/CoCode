//
//  CCPlatformIcon.m
//  CoCode
//
//  Created by wuxueqian on 15/12/8.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCPlatformIcon.h"

@interface CCPlatformIcon()

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) CCSharePlatform platformTag;

@end

@implementation CCPlatformIcon

- (instancetype)initWithPlatformInfoDict:(NSDictionary *)dict{
    self = [super init];
    
    if (self) {
        self.imageName = [dict objectForKey:@"image"];
        self.text = [dict objectForKey:@"text"];
        self.platformTag = [[dict objectForKey:@"platformTag"] integerValue];
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0, 60.0, 60.0)];
    self.icon.contentMode = UIViewContentModeScaleAspectFill;
    self.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"CCShareResource.bundle/images/%@", self.imageName]];
    [self addSubview:self.icon];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 68.0, 60.0, 20)];
    self.titleLabel.font = [UIFont systemFontOfSize:12.0];
    self.titleLabel.textColor = kFontColorBlackDark;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = self.text;
    [self addSubview:self.titleLabel];
    
    self.button = [[UIButton alloc] initWithFrame:self.bounds];
    self.button.backgroundColor = [UIColor clearColor];
    self.button.tag = self.platformTag;
    [self.button bk_addEventHandler:^(id sender) {
        self.buttonBlock();
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
    
}

@end
