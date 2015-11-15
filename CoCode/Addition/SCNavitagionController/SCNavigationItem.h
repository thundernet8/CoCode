//
//  SCNavigationItem.h
//  v2ex-iOS
//
//  Created by Singro on 5/25/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCBarButtonItem;
@interface SCNavigationItem : NSObject

@property (nonatomic, strong  ) SCBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) NSArray *leftBarButtonItems; //more items
@property (nonatomic, strong  ) SCBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) NSArray *rightBarButtonItems; //more items
@property (nonatomic, copy    ) NSString        *title;

@property (nonatomic, readonly) UIView          *titleView;
@property (nonatomic, readonly) UILabel         *titleLabel;

@end
