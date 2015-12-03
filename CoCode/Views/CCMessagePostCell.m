//
//  CCMessagePostCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMessagePostCell.h"
#import <DTCoreText.h>
#import <NSAttributedString+YYText.h>
#import "CCTextAttachment.h"
#import "NSString+AttachmentParser.h"

#import "SCCircularRefreshView.h"
#import <IDMPhotoBrowser.h>
#import "CoCodeAppDelegate.h"

static NSInteger const kAvatarHeight = 40;
static NSInteger const kFontSize = 15;

@interface CCMessagePostCell() <DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, IDMPhotoBrowserDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic) CGFloat timeLabelHeight;
@property (nonatomic) unsigned long timestamp;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) DTAttributedTextView *contentLabel;
@property (nonatomic) CGFloat contentLabelHeight;

@property (nonatomic) BOOL isMe;

@property (nonatomic, strong) NSMutableArray *imageUrls;
@property (nonatomic, strong) NSURL *lastActionLink;
@property (nonatomic, strong) UIImage *lastActionImage;

@end

@implementation CCMessagePostCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.imageUrls = [NSMutableArray array];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhiteDark;
        self.contentView.clipsToBounds = YES;
        
        self.needTimeLabel = NO;
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 20.0)];
        self.timeLabel.textColor = kFontColorBlackLight;
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.font = [UIFont systemFontOfSize:12.0];
        //[self addSubview:self.timeLabel];
        
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.layer.cornerRadius = kAvatarHeight/2.0;
        self.avatarImageView.clipsToBounds = YES;
        [self addSubview:self.avatarImageView];
        
        self.avatarButton = [[UIButton alloc] init];
        [self addSubview:self.avatarButton];
        
        self.contentLabel = [[DTAttributedTextView alloc] init];
                
        self.contentLabel.contentInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        self.contentLabel.backgroundColor = kCellHighlightedColor;
        self.contentLabel.tintColor = kFontColorBlackDark;
        self.contentLabel.layer.cornerRadius = 5.0;
        self.contentLabel.scrollEnabled = NO;
        self.contentLabel.textDelegate = self;
        self.contentLabel.shouldDrawImages = NO;
        self.contentLabel.shouldDrawLinks = YES;
        [self addSubview:self.contentLabel];
        
        
        @weakify(self);
        [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            @strongify(self);
            self.backgroundColor = kCellHighlightedColor;
        }];
    }
    
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    
    _cellHeight = 0;
    _contentLabelHeight = 0;
    _needTimeLabel = NO;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setNeedTimeLabel:(BOOL)needTimeLabel{
    
    _needTimeLabel = needTimeLabel;
    
    _timeLabelHeight = 25.0;
}

- (CCMessagePostCell *)configureWithMessagePost:(CCTopicPostModel *)post{
    
    //Time label

    if (_needTimeLabel) {
        self.timeLabel.text = [CCHelper timeDetailedIntervalStringWithDate:post.postCreatedTime];
        [self addSubview:self.timeLabel];
    }
    
    //Avatar
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:post.postUserAvatar] placeholderImage:[UIImage imageNamed:@"default_avatar_3"]];
    
    self.isMe = post.postYours; //TODO 聊天气泡
    
    //Content
    [self configureTextViewWithPostModel:post];
    
    return self;
}

- (void)configureTextViewWithPostModel:(CCTopicPostModel *)post{
    
    post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"<h2></h2>" withString:@""];

    DTCSSStylesheet *css = [[DTCSSStylesheet alloc] initWithStyleBlock:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"topic" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil]];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:CGSizeMake(kScreenWidth-40-kAvatarHeight, CGFLOAT_MAX)], DTMaxImageSize,
                                    @"Arial", DTDefaultFontFamily, @"blue", DTDefaultLinkHighlightColor, css, DTDefaultStyleSheet, kFontColorBlackDark, DTDefaultTextColor, [NSNumber numberWithInteger:kFontSize], DTDefaultFontSize, nil];
    [options setObject:[NSURL URLWithString:@"http://cocode.cc"] forKey:NSBaseURLDocumentOption];
    NSAttributedString *aString = [[NSAttributedString alloc] initWithHTMLData:[post.postContent dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil];
    self.contentLabel.attributedString = aString;
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:aString];
    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:CGRectMake(0, 0, kScreenWidth-10-kAvatarHeight-10-10, CGFLOAT_HEIGHT_UNKNOWN) range:NSMakeRange(0, aString.length)];
    //self.contentLabel.textLayout = layout;
    self.contentLabelHeight = [layoutFrame frame].size.height+10;
    
    
    
    CGFloat timeLabelHeight = 0.0;
    if (self.needTimeLabel) {
        timeLabelHeight = 25.0;
        CGFloat timeLabelWidth = [self.timeLabel sizeThatFits:CGSizeMake(kScreenWidth, 20.0)].width + 8;
        self.timeLabel.frame = CGRectMake(kScreenWidth/2.0-timeLabelWidth/2.0, 5.0, timeLabelWidth, timeLabelHeight-5);
    }
    
    
    if (self.isMe) {
        self.avatarImageView.frame = CGRectMake(kScreenWidth-kAvatarHeight-10, timeLabelHeight+5, kAvatarHeight, kAvatarHeight);
        self.contentLabel.frame = CGRectMake(10.0, timeLabelHeight+5, kScreenWidth-10-kAvatarHeight-10-10, self.contentLabelHeight);
    }else{
        self.avatarImageView.frame = CGRectMake(10, timeLabelHeight+5, kAvatarHeight, kAvatarHeight);
        self.contentLabel.frame = CGRectMake(10.0+kAvatarHeight+10, timeLabelHeight+5, [layoutFrame frame].size.width, self.contentLabelHeight);
    }
    
}


- (CGFloat)getCellHeight{

    if (self.cellHeight) {
        return self.cellHeight;
    }
    
    self.contentLabelHeight = self.contentLabel.size.height;
    
    self.cellHeight = MAX(kAvatarHeight, self.contentLabelHeight) + _timeLabelHeight + 20;
    
    NSLog(@"getCellHeight%f / %f", self.cellHeight, self.contentLabelHeight);
    
    return self.cellHeight;

}




#pragma mark - DT Delegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    if ([attachment isKindOfClass:[DTImageTextAttachment class]])
    {
        
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;
        imageView.userInteractionEnabled = YES;
        if ([attachment.contentURL.absoluteString hasPrefix:@"//cocode.cc"]) {
            attachment.contentURL = [NSURL URLWithString:[@"http:" stringByAppendingString:attachment.contentURL.absoluteString]];
        }
        imageView.url = attachment.contentURL;
        
        
        //Collect image urls for gallery
        if (![attachment.contentURL.absoluteString containsString:@"images/emoji"]) {
            [self.imageUrls addObject:attachment.hyperLinkURL?attachment.hyperLinkURL:imageView.url];
        }
        
        DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:imageView.bounds];
        button.minimumHitSize = CGSizeMake(25, 25);
        button.URL = attachment.hyperLinkURL?attachment.hyperLinkURL:imageView.url;
        
        if (kSetting.nonePicsMode && ![attachment.contentURL.absoluteString containsString:@"images/emoji"]) {
            UIImage *placeHolderImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"placeholder-image" ofType:@"png"]]];
            imageView.image = placeHolderImage;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            
            button.GUID = attachment.hyperLinkGUID;
            
            
            // use normal push action for opening URL
            [button bk_addEventHandler:^(id sender) {
                
                SCCircularRefreshView *loadingView = [[SCCircularRefreshView alloc] initWithFrame:CGRectMake(imageView.width/2.0-12.5, imageView.height/2.0-12.5, 25.0, 25.0)];
                loadingView.timeOffset = 0;
                loadingView.loadingImageView.tintColor = [UIColor grayColor];
                [loadingView beginRefreshing];
                
                [imageView addSubview:loadingView];
                
                [imageView sd_setImageWithURL:imageView.url placeholderImage:placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                    [loadingView removeFromSuperview];
                    
                    [button bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
                    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
                }];
            } forControlEvents:UIControlEventTouchUpInside];
            
            
        }else{
            // sets the image if there is one
            imageView.image = [(DTImageTextAttachment *)attachment image];
            if (![attachment.contentURL.absoluteString containsString:@"images/emoji"])
            {
                button.GUID = attachment.hyperLinkGUID;
                [button addTarget:self action:@selector(imagePushed:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
        [button addGestureRecognizer:longPress];
        
        [imageView addSubview:button];
        
        return imageView;
    }
    
    return nil;
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            if ([[UIApplication sharedApplication] canOpenURL:self.lastActionLink]) {
                [[UIApplication sharedApplication] openURL:self.lastActionLink];
            }
            break;
            
        case 1:
            
            if (self.lastActionImage) {
                UIImageWriteToSavedPhotosAlbum(self.lastActionImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
            break;
            
        default:
            break;
    }
    
}

#pragma mark Actions

- (void)linkPushed:(DTLinkButton *)button
{
    NSURL *URL = button.URL;
    
    if ([[UIApplication sharedApplication] canOpenURL:[URL absoluteURL]])
    {
        [[UIApplication sharedApplication] openURL:[URL absoluteURL]];
    }
    else
    {
        if (![URL host] && ![URL path])
        {
            
            // possibly a local anchor link
            NSString *fragment = [URL fragment];
            
            if (fragment)
            {
                [self.contentLabel scrollToAnchorNamed:fragment animated:NO];
            }
        }
    }
}

- (void)imagePushed:(DTLinkButton *)button
{
    
    NSArray *photos = [IDMPhoto photosWithURLs:self.imageUrls];
    
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:self.nav.view];
    browser.delegate = self;
    browser.displayActionButton = NO;
    browser.displayArrowButton = NO;
    browser.displayCounterLabel = YES;
    [browser setInitialPageIndex:0];
    
    [AppDelegate.window.rootViewController presentViewController:browser animated:YES completion:nil];
}

- (void)linkLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        DTLinkButton *button = (id)[gesture view];
        button.highlighted = NO;
        DTLazyImageView *imageView = (id)[button superview];
        self.lastActionLink = button.URL;
        self.lastActionImage = imageView.image;
        
        if ([[UIApplication sharedApplication] canOpenURL:[button.URL absoluteURL]])
        {
            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:[[button.URL absoluteURL] description] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open in Safari", nil), NSLocalizedString(@"Save Picture", nil), nil];
            
            [action showFromRect:button.frame inView:button.superview animated:YES];
        }
    }
}

#pragma mark - Selector

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (!error) {
        [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Picture Saved Successfully", nil)];
    }else{
        [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_error"] withText:NSLocalizedString(@"Picture Saved Failure", nil)];
    }
}





#pragma mark - Public Method

- (CGFloat)ggetCellHeight{
    
    self.cellHeight = [self.contentLabel.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:kScreenWidth-55].height+60;
    
    return self.cellHeight;
}


@end
