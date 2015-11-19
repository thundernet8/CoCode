//
//  CCUserModel.h
//  CoCode
//
//  Created by wuxueqian on 15/11/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCMemberModel.h"

@interface CCUserModel : NSObject

@property (nonatomic, strong) CCMemberModel *member;

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign, getter = isLogin) BOOL login;

+ (CCUserModel *)getUserWithLoginRespondObject:(NSDictionary *)respondeObject;

@end
