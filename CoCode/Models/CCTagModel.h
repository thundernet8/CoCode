//
//  CCTagModel.h
//  CoCode
//
//  Created by wuxueqian on 15/11/17.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCTagModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic) NSInteger count;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

@interface CCTagsModel : NSObject

@property (nonatomic, strong) NSArray *tagList;

+ (CCTagsModel *)getTagsModelFromResponseObject:(id)responseObject;

@end
