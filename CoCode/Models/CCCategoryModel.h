//
//  CCCategoryModel.h
//  CoCode
//
//  Created by wuxueqian on 15/11/16.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCCategoryModel : NSObject

@property (nonatomic, copy) NSNumber *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSString *des;
@property (nonatomic, copy) NSNumber *parnet;
@property (nonatomic, strong) NSURL *url;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
