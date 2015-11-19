//
//  CCTagModel.m
//  CoCode
//
//  Created by wuxueqian on 15/11/17.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTagModel.h"
#import "HTMLParser.h"

@implementation CCTagModel

- (instancetype)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        self.name = [dict objectForKey:@"text"];
        self.slug = [dict objectForKey:@"id"];
        self.url = [NSURL URLWithString:self.slug relativeToURL:[NSURL URLWithString:@"http://cocode.cc/tags"]];
        self.count = [[dict objectForKey:@"count"] integerValue];
    }
    
    return self;
}

@end


@implementation CCTagsModel

- (instancetype)initWithResponseObject:(NSDictionary *)responseObject{
    self = [super init];
    if (self) {
        NSArray *tagObjects = [responseObject objectForKey:@"tags"];
        NSMutableArray *tagList = [NSMutableArray array];
        for (NSDictionary *dict in tagObjects) {
            CCTagModel *tag = [[CCTagModel alloc] initWithDict:dict];
            [tagList addObject:tag];
        }
        self.tagList = [NSArray arrayWithArray:tagList];
    }
    
    return self;
}

+ (CCTagsModel *)getTagsModelFromResponseObject:(id)responseObject{
    
    CCTagsModel *model = [[self alloc] initWithResponseObject:responseObject];
    if (model) {
        return model;
    }
    
    return nil;
}

@end