//
//  CCTopicReplyCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicReplyCell.h"
#import <IDMPhotoBrowser.h>

#import "CoCodeAppDelegate.h"

#define kReplyFontSize 14.0

@interface CCTopicReplyCell() <UITextViewDelegate, IDMPhotoBrowserDelegate>

@property (nonatomic, strong) UITextView *textView;

@end

@implementation CCTopicReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhite;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textView = [self createAttributedTextView];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithData:[_post.postContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    
    self.textView.font = [UIFont systemFontOfSize:kReplyFontSize];
    
    self.textHeight = [self.textView sizeThatFits:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX)].height;
    self.textView.frame = CGRectMake(10.0, 5.0, kScreenWidth-20.0, self.textHeight);
}


- (UITextView *)createAttributedTextView{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];

    
    textView.backgroundColor = [UIColor whiteColor];
    textView.textColor = kFontColorBlackDark;
    textView.font = [UIFont systemFontOfSize:kReplyFontSize];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    textView.tintColor = kColorPurple;
    
    textView.delegate = self;
    
    [self addSubview:textView];
    
    
    return textView;
    
}

#pragma mark - UITextview delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    UIApplication *app = [UIApplication sharedApplication];
    if ([[URL scheme] isEqualToString:@"applewebdata"]) {
        NSURL *httpUrl = [NSURL URLWithString:[URL.absoluteString stringByReplacingOccurrencesOfString:@"applewebdata" withString:@"http"]];
        NSArray *photos = [IDMPhoto photosWithURLs:@[httpUrl]];
        
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:self.nav.view];
        browser.delegate = self;
        browser.displayActionButton = NO;
        browser.displayArrowButton = NO;
        browser.displayCounterLabel = YES;
        [browser setInitialPageIndex:0];
        
        [AppDelegate.window.rootViewController presentViewController:browser animated:YES completion:nil];
        return YES;
    }
    
    if ([app canOpenURL:URL]) {
        [app openURL:URL];
        
        return YES;
    }
    return NO;
}

#pragma mark - Public Class Method

+ (CGFloat)getCellHeightWithPostModel:(CCTopicPostModel *)post{
    
    if (!post) {
        return 0;
    }
    
    @autoreleasepool {
        UITextView *textView = [[UITextView alloc] init];
        textView.attributedText = [[NSAttributedString alloc] initWithData:[post.postContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        textView.font = [UIFont systemFontOfSize:kReplyFontSize];
        
        CGFloat bodyHeight = [textView sizeThatFits:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX)].height;
        return bodyHeight;
    }
    
}

@end
