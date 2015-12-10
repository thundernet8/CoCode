//
//  CCShareManager.h
//  CoCode
//
//  Created by wuxueqian on 15/12/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCSharePublicHeader.h"
#import "CCShareImage.h"

typedef void(^ShareManagerSuccessBlock)(CCShareState stateCode);
typedef void(^ShareManagerFailureBlock)(NSError *error);

@interface CCShareManager : NSObject



+ (CCShareManager *)sharedManager;

- (void)showShareSheet;

- (void)setShareTitle:(NSString *)title shareContent:(NSString *)content image:(CCShareImage *)image url:(NSString *)url;

- (BOOL)handleOpenUrl:(NSURL *)url;

@end
