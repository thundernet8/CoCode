//
//  CCShareToEmail.h
//  CoCode
//
//  Created by wuxueqian on 15/12/10.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCShareObject.h"
#import "CCSharePublicHeader.h"

@interface CCShareToEmail : NSObject

+ (CCShareToEmail *)sharedInstance;

- (void)shareContent:(CCShareObject *)object success:(ShareSuccessBlock)success failure:(ShareFailureBlock)failure;

@end
