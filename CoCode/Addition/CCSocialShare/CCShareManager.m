//
//  CCShareManager.m
//  CoCode
//
//  Created by wuxueqian on 15/12/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCShareManager.h"
#import "CCSocialShareSheet.h"
#import "CCShareObject.h"
#import "CCShareToWechat.h"
#import "CCShareToQQ.h"
#import "CCShareToEmail.h"

#define kPlatforms @[@{@"image":@"wechat", @"text":NSLocalizedString(@"WeChat", nil), @"platformTag":[NSNumber numberWithInteger:CCSharePlatformWeiChat]},@{@"image":@"wechat_moment", @"text":NSLocalizedString(@"Moments", nil), @"platformTag":[NSNumber numberWithInteger:CCSharePlatformWeiChatMoments]},@{@"image":@"qq", @"text":NSLocalizedString(@"QQ", nil), @"platformTag":[NSNumber numberWithInteger:CCSharePlatformQQ]},@{@"image":@"qzone", @"text":NSLocalizedString(@"Qzone", nil), @"platformTag":[NSNumber numberWithInteger:CCSharePlatformQzone]},@{@"image":@"safari", @"text":NSLocalizedString(@"Safari", nil), @"platformTag":[NSNumber numberWithInteger:CCSharePlatformSafari]}, @{@"image":@"email", @"text":NSLocalizedString(@"Email", nil), @"platformTag":[NSNumber numberWithInteger:CCSharePlatformEmail]}, @{@"image":@"copy", @"text":NSLocalizedString(@"Copy", nil), @"platformTag":[NSNumber numberWithInteger:CCSharePlatformCopy]}]

@interface CCShareManager() <CCSocialShareDelegate>

@property (nonatomic, strong) CCShareObject *shareObject;

@end

@implementation CCShareManager

+ (CCShareManager *)sharedManager{
    
    static CCShareManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (void)showShareSheet{
    
    [[CCSocialShareSheet sharedInstance] showShareSheetWithPlatforms:kPlatforms];
    [CCSocialShareSheet sharedInstance].delegate = self;
    
}

- (void)setShareTitle:(NSString *)title shareContent:(NSString *)content image:(CCShareImage *)image url:(NSString *)url{
    
    CCShareObject *object = [[CCShareObject alloc] init];
    object.title = title;
    object.content = content;
    object.image = image;
    object.url= url;
    
    self.shareObject = object;
    
}

- (BOOL)handleOpenUrl:(NSURL *)url{
    
    NSLog(@"handleOpenURL: %@",url.absoluteString);
    //TencentQQ
    NSRange r = [url.absoluteString rangeOfString:kQQKey];
    if (r.location != NSNotFound) {
        return [[CCShareToQQ sharedInstance] handleOpenUrl:url];
    }
    //Weixin
    r = [url.absoluteString rangeOfString:kWeixinAppKey];
    if (r.location != NSNotFound) {
        return [[CCShareToWechat sharedInstance] handleOpenUrl:url];
    }
    return YES;
}

//Delegate Method
- (void)sharedToPlatform:(CCSharePlatform)platform{
    
    [[CCSocialShareSheet sharedInstance] dismissShareSheet];
    [self sharedToPlatform:platform success:^(CCShareState stateCode) {
        
        if (platform == CCSharePlatformCopy) {
            [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Copied to pasteboard", nil)];
        }else{
            [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Share successfully", nil)];
        }
        
        
    } failure:^(NSError *error) {
        
        [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_error"] withText:NSLocalizedString(@"Share failed", nil)];
        
    }];
    
}

#pragma mark - Private Method

- (void)sharedToPlatform:(CCSharePlatform)platform success:(ShareManagerSuccessBlock)success failure:(ShareManagerFailureBlock)failure{
    
    if (!_shareObject) {
        
        NSLog(@"set share object first");
        return;
    }
    
    switch (platform) {
        case CCSharePlatformWeiChat:
        {
            [[CCShareToWechat sharedInstance] shareContent:self.shareObject scene:WXSceneTypeSession success:^(CCShareState stateCode) {
                if (success) {
                    success(stateCode);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
            
        case CCSharePlatformWeiChatMoments:
        {
            [[CCShareToWechat sharedInstance] shareContent:self.shareObject scene:WXSceneTypeTimeline success:^(CCShareState stateCode) {
                if (success) {
                    success(stateCode);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
            
        case CCSharePlatformQQ:
        {
            [[CCShareToQQ sharedInstance] shareContent:self.shareObject scene:QQSceneTypeSession success:^(CCShareState stateCode) {
                if (success) {
                    success(stateCode);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
            
        case CCSharePlatformQzone:
        {
            [[CCShareToQQ sharedInstance] shareContent:self.shareObject scene:QQSceneTypeQzone success:^(CCShareState stateCode) {
                if (success) {
                    success(stateCode);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
            
        case CCSharePlatformSafari:
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_shareObject.url]];
            break;
            
        case CCSharePlatformEmail:
        {
            [[CCShareToEmail sharedInstance] shareContent:self.shareObject success:^(CCShareState stateCode) {
                if (success) {
                    success(stateCode);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            
        case CCSharePlatformCopy:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.shareObject.url;
            
            if (success) {
                success(CCShareStateSuccess);
            }
        }
            
        default:
            break;
    }
}


//NSLocalizedStringFromTableInBundle(nil, nil, nil, nil)

@end
