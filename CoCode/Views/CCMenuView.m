//
//  CCMenuView.m
//  CoCode
//
//  Created by wuxueqian on 15/11/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMenuView.h"
#import "CCMenuSectionView.h"
#import "CCMenuSectionView.h"

@interface CCMenuView()

@property (nonatomic, strong) UIView      *backgroundContainView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIImageView *leftShadowImageView;
@property (nonatomic, strong) UIView      *leftShdowImageMaskView;

@property (nonatomic, strong) CCMenuSectionView *sectionView;

@end

@implementation CCMenuView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        [self configureViews];
        [self configureShadow];
        
        //TODO Notification
    }
    return self;
}

#pragma mark - Life Cycle

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure Views

- (void)configureViews{
    //Add Background for Menu View
    self.backgroundContainView = [[UIView alloc] init];
    self.backgroundContainView.clipsToBounds = YES;
    [self addSubview:self.backgroundContainView];
    
    //Add Background Image for Menu View
    self.backgroundImageView = [[UIImageView alloc] init];
    [self.backgroundContainView addSubview:self.backgroundImageView];
    
    //Add Section View for Menu View
    self.sectionView = [[CCMenuSectionView alloc] init];
    [self addSubview:self.sectionView];
    
    //Set Selectting Block
    @weakify(self);
    [self.sectionView setDidSelectedIndexBlock:^(NSInteger index) {
        @strongify(self);
        if (self.didSelectedIndexBlock) {
            self.didSelectedIndexBlock(index);
        }
    }];
}

- (void)configureShadow{
    //Left Shadow Mask
    self.leftShdowImageMaskView = [[UIView alloc] init];
    self.leftShdowImageMaskView.clipsToBounds = YES;
    [self addSubview:self.leftShdowImageMaskView];
    
    //Left Shadow
    UIImage *shadowImage = [UIImage imageNamed:@"Navi_Shadow"];
    shadowImage = shadowImage.imageForCurrentTheme;
    self.leftShadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
    self.leftShadowImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.leftShadowImageView.alpha = 0.0;
    [self.leftShdowImageMaskView addSubview:self.leftShadowImageView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //Background
    self.backgroundColor = kBackgroundColorWhiteDark;
    
    self.backgroundContainView.frame = CGRectMake(0.0, 0.0, self.width, kScreenHeight);
    self.backgroundImageView.frame = CGRectMake(kScreenWidth, 0.0, kScreenWidth, kScreenHeight);
    
    //Shadow
    self.leftShdowImageMaskView.frame = CGRectMake(self.width, 0.0, 10.0, kScreenHeight);
    self.leftShadowImageView.frame = CGRectMake(-5.0, 0.0, 10.0, kScreenHeight);
    
    //Section
    self.sectionView.frame = CGRectMake(0.0, 0.0, self.width, kScreenHeight);
}

#pragma mark - Public Methods

- (void)setOffsetProgress:(CGFloat)progress{
    progress = MIN(MAX(progress, 0.0), 1.0);
    
    self.backgroundImageView.x = self.width - kScreenWidth/2*progress;
    
    self.leftShadowImageView.alpha = progress;
    self.leftShadowImageView.x = -5 + progress*5;
}

- (void)setBlurredImage:(UIImage *)blurredImage{
    self.blurredImage = blurredImage;
    self.backgroundImageView.image = self.blurredImage;
}

@end
