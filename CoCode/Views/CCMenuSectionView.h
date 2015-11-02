//
//  CCMenuSectionView.h
//  CoCode
//
//  Created by wuxueqian on 15/11/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCMenuSectionCell.h"

@interface CCMenuSectionView : UIView

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) void (^didSelectedIndexBlock)(NSInteger index);

- (void)setDidSelectedIndexBlock:(void (^)(NSInteger))didSelectedIndexBlock;

@end
