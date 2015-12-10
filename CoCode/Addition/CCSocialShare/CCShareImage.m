//
//  CCShareImage.m
//  CoCode
//
//  Created by wuxueqian on 15/12/9.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCShareImage.h"

@implementation CCShareImage

- (instancetype)initWithImageUrl:(NSString *)imageUrl
{
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.compressedData = UIImageJPEGRepresentation([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]], 0.3);
            self.compressedImage = [UIImage imageWithData:self.compressedData];
        });
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.compressedData = UIImageJPEGRepresentation(image, 0.3);
        self.compressedImage = [UIImage imageWithData:self.compressedData];
    }
    return self;
}

@end
