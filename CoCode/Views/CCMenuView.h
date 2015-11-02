//
//  CCMenuView.h
//  CoCode
//
//  Created by wuxueqian on 15/11/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCMenuView : UIView

@property (nonatomic, copy) void(^didSelectedIndexBlock)(NSInteger index);

@property (nonatomic, strong) UIImage *blurredImage;

- (void)setDidSelectedIndexBlock:(void (^)(NSInteger))didSelectedIndexBlock;

- (void)setOffsetProgress:(CGFloat)progress;

@end
