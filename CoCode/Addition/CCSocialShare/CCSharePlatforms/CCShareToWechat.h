//
//  CCShareToWechat.h
//  CoCode
//
//  Created by wuxueqian on 15/12/9.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCSharePublicHeader.h"
#import "CCShareObject.h"

typedef NS_ENUM(NSUInteger, WXSceneType) {
    WXSceneTypeSession,
    WXSceneTypeTimeline,
};

@interface CCShareToWechat : NSObject

+ (CCShareToWechat *)sharedInstance;

- (void)shareContent:(CCShareObject *)object scene:(WXSceneType)scene success:(ShareSuccessBlock)success failure:(ShareFailureBlock)failure;

- (BOOL)handleOpenUrl:(NSURL *)url;

@end
