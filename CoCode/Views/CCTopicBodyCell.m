//
//  CCTopicBodyCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicBodyCell.h"

#import <IDMPhotoBrowser.h>
#import <AnimatedGIFImageSerialization.h>
#import "CCTopicPostModel.h"
#import "CoCodeAppDelegate.h"

static const CGFloat kBodyFontSize = 16.0;

@interface CCTopicBodyCell() <IDMPhotoBrowserDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITextView *bodyLabel;

@property (nonatomic, strong) UIView *border;

@property (nonatomic, assign) NSInteger bodyHeight;

//Attributed resources
@property (nonatomic, strong) NSMutableArray *attributedLabelArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *imageButtonArray;
@property (nonatomic, strong) NSMutableArray *imageUrls;


@end

@implementation CCTopicBodyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhite;
        
        self.attributedLabelArray = [NSMutableArray array];
        self.imageArray = [NSMutableArray array];
        self.imageButtonArray = [NSMutableArray array];
        self.imageUrls = [NSMutableArray array];
        
        self.bodyLabel = [self createAttributedTextView];

        
        
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //TODO
    //CCTopicModel *topic = self.topic;
    
    //CCTopicPostModel *post = self.topic.posts[0];
    //self.bodyLabel.attributedText = [[NSAttributedString alloc] initWithString:post.postContent attributes:nil];
    self.border.frame = CGRectMake(10.0, self.height - 0.5, kScreenWidth - 20, 0.5);
    [self layoutContent];
}

- (void)layoutContent{
    CCTopicPostModel *post = self.topic.posts.count > 0 ? self.topic.posts[0] : nil;
    if (post && post.postContent.length > 0) {
        post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"<h2></h2>" withString:@""];
        self.bodyLabel.attributedText = [[NSAttributedString alloc] initWithData:[post.postContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        self.bodyLabel.font = [UIFont systemFontOfSize:kBodyFontSize];

        self.bodyHeight = [self.bodyLabel sizeThatFits:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX)].height;
        self.bodyLabel.frame = CGRectMake(10.0, 5.0, kScreenWidth-20.0, self.bodyHeight);

        //NSLog(@"%@",post.postContent);
        


        

    }

    
    
}

#pragma mark - Setter

- (void)setTopic:(CCTopicModel *)topic{
    _topic = topic;
}

#pragma mark - Create View

- (UIImageView *)createImageView{
    UIImageView *imageView = [[UIImageView alloc] init];
    
    imageView.backgroundColor = kBackgroundColorWhiteDark;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] init];
    [self addSubview:button];
    
    [self.imageArray addObject:imageView];
    [self.imageButtonArray addObject:button];
    
    return imageView;
}

- (UITextView *)createAttributedTextView{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = kFontColorBlackDark;
    textView.font = [UIFont systemFontOfSize:kBodyFontSize];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    textView.tintColor = kColorPurple;
    
    
//    textView.linkTextAttributes = @{NSBackgroundColorAttributeName:kColorPurple, NSForegroundColorAttributeName:kColorPurple, NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleNone], NSUnderlineColorAttributeName:[UIColor clearColor]};
    textView.delegate = self;
    
    [self addSubview:textView];
    
    
    [self.attributedLabelArray addObject:textView];
    
    return textView;
    
}

#pragma mark - TextView delegate

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

+ (CGFloat)getCellHeightWithTopicModel:(CCTopicModel *)topic{
    CCTopicPostModel *post = topic.posts[0];
    post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"<h2></h2>" withString:@""];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.font = [UIFont systemFontOfSize:kBodyFontSize];
    textView.attributedText = [[NSAttributedString alloc] initWithData:[post.postContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    textView.font = [UIFont systemFontOfSize:kBodyFontSize];

    return [textView sizeThatFits:CGSizeMake(kScreenWidth-20, CGFLOAT_MAX)].height;
}

@end
