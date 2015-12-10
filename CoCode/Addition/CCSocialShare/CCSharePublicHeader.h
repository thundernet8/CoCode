//
//  CCSharePublicHeader.h
//  CoCode
//
//  Created by wuxueqian on 15/12/8.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#ifndef CCShare_Public_h
#define CCShare_Public_h

#define CCAppDomain @"com.wuxueqian.cocode"

//Platform

typedef NS_ENUM(NSUInteger, CCSharePlatform) {
    CCSharePlatformWeiChat = 1,
    CCSharePlatformWeiChatMoments,
    CCSharePlatformQQ,
    CCSharePlatformQzone,
    CCSharePlatformWeiBo,
    CCSharePlatformFacebook,
    CCSharePlatformTwitter,
    CCSharePlatformSafari,
    CCSharePlatformEmail,
    CCSharePlatformCopy
};

//Share state

typedef NS_ENUM(NSUInteger, CCShareState) {
    CCShareStateStart         = 1<<0,
    CCShareStateSuccess       = 1<<1,
    CCShareStateFailure       = 1<<2,
    CCShareStateCancel        = 1<<3,
    CCShareStateUninstalled   = 1<<4,
    CCShareStateuNsupported   = 1<<5
};

//Share block

typedef void(^ShareSuccessBlock)(CCShareState stateCode);
typedef void(^ShareFailureBlock)(NSError *error);

#endif
