//
//  CCShareToEmail.m
//  CoCode
//
//  Created by wuxueqian on 15/12/10.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCShareToEmail.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface CCShareToEmail() <MFMailComposeViewControllerDelegate>

@property (nonatomic, copy) ShareSuccessBlock success;
@property (nonatomic, copy) ShareFailureBlock failure;

@end

@implementation CCShareToEmail

+ (CCShareToEmail *)sharedInstance{
    
    static CCShareToEmail *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CCShareToEmail alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)shareContent:(CCShareObject *)object success:(ShareSuccessBlock)success failure:(ShareFailureBlock)failure{
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    
    if (!object.title.length) {
        NSError *error = [[NSError alloc] initWithDomain:CCAppDomain code:CCShareStateFailure userInfo:nil];
        failure(error);
    }
    
    [mc setSubject:object.title];
    if (object.image.compressedData) {
        [mc addAttachmentData:object.image.compressedData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"%@.jpg", object.title]];
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow.rootViewController presentViewController:mc animated:YES completion:^{
        self.success = success;
        self.failure = failure;
    }];
    
}

#pragma mark - Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    BOOL status;
    switch (result)
    {
        case MFMailComposeResultCancelled:
        case MFMailComposeResultSaved:
        case MFMailComposeResultFailed:
            status = NO;
            break;
        case MFMailComposeResultSent:
            status = YES;
            break;
        default:
            break;
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow.rootViewController dismissViewControllerAnimated:YES completion:^(void){
        
        if (status) {
            _success ? _success(CCShareStateSuccess) : nil;
        }else{
            NSError *error = [[NSError alloc] initWithDomain:CCAppDomain code:CCShareStateFailure userInfo:nil];
            _failure ? _failure(error) : nil;
        }
        
    }];
}

@end
