//
//  CCShareToQQ.m
//  CoCode
//
//  Created by wuxueqian on 15/12/9.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCShareToQQ.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

@interface CCShareToQQ() <TencentSessionDelegate, QQApiInterfaceDelegate>

@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, retain) TencentOAuth *tencentOAuth;
@property (nonatomic, copy) ShareSuccessBlock success;
@property (nonatomic, copy) ShareFailureBlock failure;

@end

@implementation CCShareToQQ

+ (CCShareToQQ *)sharedInstance{
    
    static CCShareToQQ *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CCShareToQQ alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    
    if (self = [super init]) {
        //set appkey and appsecret
        _appKey = kQQKey;
        _appSecret = kQQSecret;
#if !TARGET_IPHONE_SIMULATOR
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kQQKey andDelegate:self];
#endif
    }
    
    return self;
}

- (BOOL)handleOpenUrl:(NSURL *)url{
    
#if !TARGET_IPHONE_SIMULATOR
    if ([QQApiInterface isQQInstalled]) {
        return [QQApiInterface handleOpenURL:url delegate:self];
    }else{
        return [TencentOAuth HandleOpenURL:url];
    }
#endif
    
    return YES;
}

- (void)shareContent:(CCShareObject *)object scene:(QQSceneType)scene success:(ShareSuccessBlock)success failure:(ShareFailureBlock)failure{
    
    self.failure = failure;
#if !TARGET_IPHONE_SIMULATOR
    if (![QQApiInterface isQQInstalled]) {
        if(failure){
            
            NSError *error = [[NSError alloc] initWithDomain:CCAppDomain code:CCShareStateUninstalled userInfo:nil];
            failure(error);
        }
        self.failure = nil;
        return;
    }
    NSData* data = object.image.compressedData;
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:object.url]
                                title:object.title
                                description:object.content
                                previewImageData:data];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    self.success = success;
    QQApiSendResultCode sent;
    if (scene == QQSceneTypeQzone) {
        //Share to Qzone
        sent = [QQApiInterface SendReqToQZone:req];
    }else{
        //Share to QQ
        sent = [QQApiInterface sendReq:req];
    }
    
    //[self handleQQSendResult:sent];
#endif
    
}

#pragma mark - QQ Delegate

- (void)onResp:(QQBaseResp *)resp{

#if !TARGET_IPHONE_SIMULATOR
    if([resp isKindOfClass:[SendMessageToQQResp class]])
    {
        if ([resp.result isEqualToString:@"0"] ) {
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


- (void)handleQQSendResult:(QQApiSendResultCode)sendResult
{
    
    NSLog(@"%d", sendResult);
    switch (sendResult)
    {
        case EQQAPISENDSUCESS:{
            if (_success) {
                _success(CCShareStateSuccess);
            }
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            if (_failure) {
                NSError *error = [[NSError alloc] initWithDomain:CCAppDomain code:CCShareStateUninstalled userInfo:nil];
                _failure(error);
            }
            break;
        }
        case EQQAPIAPPNOTREGISTED:
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        case EQQAPIQQNOTSUPPORTAPI:
        case EQQAPISENDFAILD:
        {
            if (_failure) {
                NSError *error = [[NSError alloc] initWithDomain:CCAppDomain code:CCShareStateFailure userInfo:nil];
                _failure(error);
            }
            
            break;
        }
        default:
        {
            if (_failure) {
                NSError *error = [[NSError alloc] initWithDomain:CCAppDomain code:CCShareStateFailure userInfo:nil];
                _failure(error);
            }
            break;
        }
    }
    _success = nil;
    _failure = nil;
    
}

@end
