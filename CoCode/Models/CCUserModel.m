//
//  CCUserModel.m
//  CoCode
//
//  Created by wuxueqian on 15/11/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCUserModel.h"
#import "CCMemberModel.h"

@implementation CCUserModel

- (instancetype)initWithLoginRespondeObject:(NSDictionary *)respondObject{
    self = [super init];
    
    if (self) {
        self.member = [[CCMemberModel alloc] initWithUserDictionary:respondObject];
        self.login = YES;
    }
    
    return self;
}

+ (CCUserModel *)getUserWithLoginRespondObject:(NSDictionary *)respondeObject{
    CCUserModel *user = [[CCUserModel alloc] initWithLoginRespondeObject:respondeObject];
    CCMemberModel *member = user.member;
    
    
    return user;
}

@end
