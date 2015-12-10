//
//  CCShareToWechat.m
//  CoCode
//
//  Created by wuxueqian on 15/12/9.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCShareToWechat.h"
#import <WeixinSDK/WXApi.h>
#import <WeixinSDK/WXApiObject.h>

@interface CCShareToWechat() <WXApiDelegate>

@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, copy) ShareSuccessBlock success;
@property (nonatomic, copy) ShareFailureBlock failure;

@end

@implementation CCShareToWechat

+ (CCShareToWechat *)sharedInstance{
    
    static CCShareToWechat *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CCShareToWechat alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    
    if (self = [super init]) {
        //set appkey and appsecret
        _appKey = kWeixinAppKey;
        _appSecret = kWeixinAppSecret;
#if !TARGET_IPHONE_SIMULATOR
        [WXApi registerApp:_appKey];
#endif
    }
    
    return self;
}

- (void)shareContent:(CCShareObject *)object scene:(WXSceneType)scene success:(ShareSuccessBlock)success failure:(ShareFailureBlock)failure{
    
    self.failure = failure;
#if !TARGET_IPHONE_SIMULATOR
    if (![WXApi isWXAppInstalled]) {
        if(failure){
            
            NSError *error = [[NSError alloc] initWithDomain:CCAppDomain code:CCShareStateUninstalled userInfo:nil];
            failure(error);
        }
        self.failure = nil;
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = object.title;
    message.description = object.content;
    [message setThumbImage:[self getWXThumbImage:object.image.compressedImage]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = object.url;
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;    
    
    //Send to session or timeline
    if (scene == WXSceneTypeTimeline) {
        req.scene = WXSceneTimeline;
    }
    self.success = success;
    [WXApi sendReq:req];
#endif
    
}

#pragma mark - Wechat Delegate

- (void)onResp:(BaseResp *)resp{
    
#if !TARGET_IPHONE_SIMULATOR
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode == WXSuccess) {
            if(self.success){
                self.success(CCShareStateSuccess);
            }
        }else{
            if(self.failure){
                NSError *error = [[NSError alloc] initWithDomain:CCAppDomain code:CCShareStateFailure userInfo:nil];
                self.failure(error);
            }
        }
        
        self.failure = nil;
        self.success = nil;
    }
#endif
}

- (BOOL)handleOpenUrl:(NSURL *)url{
    
#if !TARGET_IPHONE_SIMULATOR
    return [WXApi handleOpenURL:url delegate:self];
#endif
    
    return YES;
}


#pragma mark - Private Methods

- (UIImage *)getWXThumbImage:(UIImage *)image
{
    CGFloat  size  = (image.size.width*image.size.height)/1024;
    CGFloat  scaleSize = (size<32)?1.0:(32/size);
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


@end
