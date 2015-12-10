//
//  CCMenuSectionCellView.h
//  CoCode
//
//  Created by wuxueqian on 15/11/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCMenuSectionCell : UITableViewCell

@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *badge;

+ (CGFloat)getCellHeight;

@end
