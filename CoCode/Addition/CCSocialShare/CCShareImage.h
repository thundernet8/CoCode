//
//  CCShareImage.h
//  CoCode
//
//  Created by wuxueqian on 15/12/9.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCShareImage : NSObject

@property (nonatomic, strong) NSData *compressedData;
@property (nonatomic, strong) UIImage *compressedImage;

- (instancetype)initWithImageUrl:(NSString *)imageUrl;
- (instancetype)initWithImage:(UIImage *)image;

@end
