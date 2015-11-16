//
//  CCCategoryModel.m
//  CoCode
//
//  Created by wuxueqian on 15/11/16.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCCategoryModel.h"

@implementation CCCategoryModel

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.ID = [dict objectForKey:@"ID"];
        self.name = [dict objectForKey:@"NAME"];
        self.slug = [dict objectForKey:@"SLUG"];
        self.des = [dict objectForKey:@"DESCRIPTION"];
        self.parnet = [dict objectForKey:@"PARENT"];
        self.url = [NSURL URLWithString:[@"http://cocode.cc/c/" stringByAppendingString:self.slug]];
    }
    
    return self;
}

@end
