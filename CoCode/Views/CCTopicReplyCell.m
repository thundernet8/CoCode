//
//  CCTopicReplyCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicReplyCell.h"
#import <IDMPhotoBrowser.h>
#import <UIImageView+WebCache.h>
#import "CoCodeAppDelegate.h"

#import <DTCoreText.h>

#define kReplyFontSize 16.0
#define kAvatarHeight 30.0

@interface CCTopicReplyCell() <DTAttributedTextContentViewDelegate, IDMPhotoBrowserDelegate>

@property (nonatomic, strong) DTAttributedTextView *textView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *praiseImageView;
@property (nonatomic, strong) UILabel *praiseCountLabel;

@end

@implementation CCTopicReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhite;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.clipsToBounds = YES;
        self.avatarImageView.layer.cornerRadius = kAvatarHeight/2.0;
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.avatarImageView];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor colorWithRed:0.533 green:0.565 blue:0.592 alpha:1.000];
        self.nameLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.nameLabel];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.textColor = [UIColor colorWithWhite:0.867 alpha:1.000];
        self.timeLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.timeLabel];
        
        self.praiseImageView = [[UIImageView alloc] init];
        self.praiseImageView.clipsToBounds = YES;
        self.praiseImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.praiseImageView.image = [UIImage imageNamed:@"icon_praise"];
        [self addSubview:self.praiseImageView];
        
        self.praiseCountLabel = [[UILabel alloc] init];
        self.praiseCountLabel.textColor = [UIColor colorWithWhite:0.500 alpha:1.000];
        self.praiseCountLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.praiseCountLabel];
        
        self.textView = [self createAttributedTextView];
    }
    
    return self;
}

- (void)prepareForReuse{
    

}

- (void)layoutSubviews{

    [super layoutSubviews];

    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_post.postUserAvatar] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    self.avatarImageView.frame = CGRectMake(10.0, 10.0, kAvatarHeight, kAvatarHeight);
    
    self.nameLabel.text = _post.postUserDisplayname.length ? _post.postUserDisplayname : _post.postUsername;
    self.nameLabel.frame = CGRectMake(50.0, 10.0, 100.0, 18.0);
    
    self.timeLabel.text = [CCHelper timeIntervalStringWithDate:_post.postCreatedTime];
    self.timeLabel.frame = CGRectMake(50.0, 29.0, 100.0, 12.0);
    
    self.praiseImageView.frame = CGRectMake(kScreenWidth-55, 12.0, 20.0, 20.0);
    self.praiseCountLabel.text = [NSString stringWithFormat:@"%d", (int)_post.postLikeCount];
    self.praiseCountLabel.frame = CGRectMake(kScreenWidth-30, 13.0, 30.0, 20.0);
    
    
    
}

- (void)setPost:(CCTopicPostModel *)post{
    _post = post;

    [self configureTextView];

}

- (void)configureTextView{
    
    _post.postContent = [_post.postContent stringByReplacingOccurrencesOfString:@"<h2></h2>" withString:@""];
    
    void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
        
        for (DTHTMLElement *oneChildElement in element.childNodes)
        {
            
            //if an element is larger than twice the font size put it in it's own block
//            if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
//            {
//                oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
//                oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
//                oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
//            }
        }
    };
    
    DTCSSStylesheet *css = [[DTCSSStylesheet alloc] initWithStyleBlock:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"topic" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil]];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:CGSizeMake(kScreenWidth, CGFLOAT_MAX)], DTMaxImageSize,
                                    @"Arial", DTDefaultFontFamily, @"blue", DTDefaultLinkHighlightColor, callBackBlock, DTWillFlushBlockCallBack, css, DTDefaultStyleSheet, kFontColorBlackDark, DTDefaultTextColor, @kReplyFontSize, DTDefaultFontSize, nil];
    [options setObject:[NSURL URLWithString:@"http://cocode.cc"] forKey:NSBaseURLDocumentOption];
    
    self.textView.attributedString = [[NSAttributedString alloc] initWithHTMLData:[_post.postContent dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil];
    
    self.textView.frame = CGRectMake(45.0, 45.0, kScreenWidth-55.0, [self getCellHeight]-60);
    
}

#pragma mark - Create Attributed View

- (DTAttributedTextView *)createAttributedTextView{
    DTAttributedTextView *textView = [[DTAttributedTextView alloc] initWithFrame:CGRectZero];

    textView.backgroundColor = [UIColor clearColor];
    //textView.textColor = kFontColorBlackDark;
    //textView.font = [UIFont systemFontOfSize:kReplyFontSize];
    textView.scrollEnabled = NO;
    //textView.editable = NO;
    
    
    textView.textDelegate = self;
    
    [self addSubview:textView];
    
    return textView;
    
}

#pragma mark - UITextview delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    UIApplication *app = [UIApplication sharedApplication];
    if ([[URL scheme] isEqualToString:@"applewebdata"]) {
        NSURL *httpUrl = [NSURL URLWithString:[URL.absoluteString stringByReplacingOccurrencesOfString:@"applewebdata://" withString:@"http://"]];
        
        NSString *suffix = [httpUrl.absoluteString substringFromIndex:httpUrl.absoluteString.length-4];
        suffix = [suffix lowercaseString];
        NSArray *suffixs = @[@".png",@".jpg",@"jpeg",@".gif",@".bmp"];
        if (![suffixs containsObject:suffix]) {
            return NO;
        }
        
        NSArray *photos = [IDMPhoto photosWithURLs:@[httpUrl]];
        
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:self.nav.view];
        browser.delegate = self;
        browser.displayActionButton = NO;
        browser.displayArrowButton = NO;
        browser.displayCounterLabel = YES;
        [browser setInitialPageIndex:0];
        
        [self.nav presentViewController:browser animated:YES completion:nil];
        return YES;
    }
    
    if ([app canOpenURL:URL]) {
        [app openURL:URL];
        
        return YES;
    }
    return NO;
}

#pragma mark - Public Method

- (CGFloat)getCellHeight{
   
    if (!self.cellHeight) {
        self.cellHeight = [self.textView.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:kScreenWidth-55].height+60;
    }
    
    return self.cellHeight;
}

@end
