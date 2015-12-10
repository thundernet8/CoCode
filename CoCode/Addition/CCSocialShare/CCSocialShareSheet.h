//
//  CCSocialShareSheet.h
//  CoCode
//
//  Created by wuxueqian on 15/12/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSharePublicHeader.h"

@class CCSocialShareSheet;
@protocol CCSocialShareDelegate <NSObject>

- (void)sharedToPlatform:(CCSharePlatform)platform;

@end

@interface CCSocialShareSheet : NSObject

@property (nonatomic, weak) id<CCSocialShareDelegate> delegate;

+ (CCSocialShareSheet *)sharedInstance;

- (void)showShareSheetWithPlatforms:(NSArray *)platforms;

- (void)dismissShareSheet;

@end
