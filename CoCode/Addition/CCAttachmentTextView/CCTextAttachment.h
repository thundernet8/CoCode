//
//  CCTextAttchment.h
//  CoCode
//
//  Created by wuxueqian on 15/11/29.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CCTextAttachmentType) {
    CCTextAttachmentTypeNone,
    CCTextAttachmentTypeImage,
    CCTextAttachmentTypeVideo,
    CCTextAttachmentTypeLink,
    CCTextAttachmentTypeMember,
    CCTextAttachmentTypeBlockquote
};

@interface CCTextAttachment : NSObject

@property (nonatomic, assign) CCTextAttachmentType type;
@property (nonatomic, copy) NSString *rawText;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSRange range;

@end

@interface CCTextAttachmentImage : CCTextAttachment

@property (nonatomic, copy) NSURL *defaultUrl;
@property (nonatomic, copy) NSURL *originalUrl;
@property (nonatomic) CGSize size;
@property (nonatomic, copy) NSString *title;

@end

@interface CCTextAttachmentString : CCTextAttachment

@property (nonatomic, copy) NSAttributedString *attributedString;
@property (nonatomic, strong) NSArray *quotes; //Likes links in string

@end

@interface CCTextAttachmentLink : CCTextAttachment

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *title;

@end