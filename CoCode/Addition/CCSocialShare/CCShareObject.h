//
//  CCShareObject.h
//  CoCode
//
//  Created by wuxueqian on 15/12/9.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCShareImage.h"

@interface CCShareObject : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) CCShareImage *image;
@property (nonatomic, copy) NSString *url;

@end
