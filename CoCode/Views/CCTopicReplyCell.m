//
//  CCTopicReplyCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicReplyCell.h"
#import <IDMPhotoBrowser.h>
#import "CCWebViewController.h"
#import <UIImageView+WebCache.h>
#import "CoCodeAppDelegate.h"
#import "CCDataManager.h"

#import <DTCoreText.h>
#import "SCCircularRefreshView.h"

#import "CCTopicViewReplyInput.h"

#define kReplyFontSize 16.0
#define kAvatarHeight 30.0

@interface CCTopicReplyCell() <DTAttributedTextContentViewDelegate, IDMPhotoBrowserDelegate, DTLazyImageViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) DTAttributedTextView *textView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *praiseButton;
@property (nonatomic, strong) UILabel *praiseCountLabel;
@property (nonatomic, strong) NSMutableArray *imageUrls;
@property (nonatomic, strong) NSURL *lastActionLink;
@property (nonatomic, strong) UIImage *lastActionImage;
@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, strong) CCTopicViewReplyInput *replyInput;

@end

@implementation CCTopicReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kCellHighlightedColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.separatorLine = [[UIView alloc] init];
        self.separatorLine.backgroundColor = kSeparatorColor;
        [self addSubview:self.separatorLine];
        
        self.imageUrls = [NSMutableArray array];
        
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
        
        self.praiseButton = [[UIButton alloc] init];
        self.praiseButton.clipsToBounds = YES;
        [self.praiseButton setImage:[UIImage imageNamed:@"icon_praise"] forState:UIControlStateNormal];
        [self addSubview:self.praiseButton];
        
        self.praiseCountLabel = [[UILabel alloc] init];
        self.praiseCountLabel.textColor = [UIColor colorWithWhite:0.500 alpha:1.000];
        self.praiseCountLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.praiseCountLabel];
        
        self.textView = [self createAttributedTextView];
        
        @weakify(self);
        [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            @strongify(self);
            self.backgroundColor = kCellHighlightedColor;
            self.separatorLine.backgroundColor = kSeparatorColor;
        }];
    }
    
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    
}

- (void)layoutSubviews{

    [super layoutSubviews];

    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_post.postUserAvatar] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    self.avatarImageView.frame = CGRectMake(10.0, 10.0, kAvatarHeight, kAvatarHeight);
    
    self.nameLabel.text = _post.postUserDisplayname.length ? _post.postUserDisplayname : _post.postUsername;
    self.nameLabel.frame = CGRectMake(50.0, 10.0, 100.0, 18.0);
    
    self.timeLabel.text = [CCHelper timeIntervalStringWithDate:_post.postCreatedTime];
    self.timeLabel.frame = CGRectMake(50.0, 29.0, 100.0, 12.0);
    
    self.praiseButton.frame = CGRectMake(kScreenWidth-55, 12.0, 20.0, 20.0);
    [self.praiseButton bk_addEventHandler:^(id sender) {
        
        [self likeActivity];
        
    } forControlEvents:UIControlEventTouchUpInside];
    self.praiseCountLabel.text = [NSString stringWithFormat:@"%d", (int)_post.postLikeCount];
    self.praiseCountLabel.frame = CGRectMake(kScreenWidth-30, 13.0, 30.0, 20.0);
    
    self.separatorLine.frame = CGRectMake(0, self.cellHeight, kScreenWidth, 0.5);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc");
}

- (void)setPost:(CCTopicPostModel *)post{
    _post = post;

    [self configureTextView];

}

- (void)configureTextView{
    
    _post.postContent = [_post.postContent stringByReplacingOccurrencesOfString:@"<h2></h2>" withString:@""];
    NSString *postContent = _post.postContent;
    if (_post.postReplyTo != (id)[NSNull null] && _replyToPost) {
        //postContent = [NSString stringWithFormat:@"<a class=\"mention\" href=\"%@/users/%@\">@%@</a>%@", kBaseUrl, _replyToPost.postUsername, _replyToPost.postUsername, _post.postContent];
        if ([postContent hasPrefix:@"<p>"]) {
            postContent = [NSString stringWithFormat:@"<p><a class=\"mention\" href=\"%@/users/%@\">@%@ </a>%@", kBaseUrl, _replyToPost.postUsername, _replyToPost.postUsername, [postContent substringWithRange:NSMakeRange(3, postContent.length-3)]];
        }else{
            postContent = [NSString stringWithFormat:@"<a class=\"mention\" href=\"%@/users/%@\">@%@ </a>%@", kBaseUrl, _replyToPost.postUsername, _replyToPost.postUsername, postContent];
        }
    }
    
    DTCSSStylesheet *css = [[DTCSSStylesheet alloc] initWithStyleBlock:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"topic" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil]];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:CGSizeMake(kScreenWidth-55.0, CGFLOAT_MAX)], DTMaxImageSize,
                                    @"Arial", DTDefaultFontFamily, css, DTDefaultStyleSheet, kFontColorBlackDark, DTDefaultTextColor, @kReplyFontSize, DTDefaultFontSize, nil];
    [options setObject:[NSURL URLWithString:@"http://cocode.cc"] forKey:NSBaseURLDocumentOption];
    
    self.textView.attributedString = [[NSAttributedString alloc] initWithHTMLData:[postContent dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil];
    self.textView.frame = CGRectMake(45.0, 45.0, kScreenWidth-55.0, CGFLOAT_HEIGHT_UNKNOWN);
    @weakify(self);
    [self.textView bk_whenTapped:^{
        @strongify(self);
        [self showActionSheet];
        //[self replyActivity];
    }];
}

#pragma mark - Create Attributed View

- (DTAttributedTextView *)createAttributedTextView{
    DTAttributedTextView *textView = [[DTAttributedTextView alloc] initWithFrame:CGRectZero];

    textView.backgroundColor = [UIColor clearColor];
    textView.scrollEnabled = NO;
    textView.textDelegate = self;
    textView.shouldDrawImages = NO;
    textView.shouldDrawLinks = YES;
    
    [self addSubview:textView];
    
    return textView;
    
}

#pragma mark - DT Delegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame{
    
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = url;
    button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
    button.GUID = identifier;
    
    // get image with normal link text
    UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
    [button setImage:normalImage forState:UIControlStateNormal];
    
    // get image for highlighted link text
    UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    // use normal push action for opening URL
    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    if ([attachment isKindOfClass:[DTVideoTextAttachment class]])
    {
        //NSURL *url = (id)attachment.contentURL;
        
        UIView *grayView = [[UIView alloc] initWithFrame:frame];
        grayView.backgroundColor = [DTColor blackColor];
        
        return grayView;
    }
    else if ([attachment isKindOfClass:[DTImageTextAttachment class]])
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
    else if ([attachment isKindOfClass:[DTIframeTextAttachment class]])
    {
        DTWebVideoView *videoView = [[DTWebVideoView alloc] initWithFrame:frame];
        videoView.attachment = attachment;
        
        return videoView;
    }
    
    return nil;
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 100) {
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
}

#pragma mark Actions

- (void)linkPushed:(DTLinkButton *)button{
    NSURL *URL = button.URL;
    
    if ([[UIApplication sharedApplication] canOpenURL:[URL absoluteURL]])
    {
        //[[UIApplication sharedApplication] openURL:[URL absoluteURL]];
        CCWebViewController *webviewVC = [[CCWebViewController alloc] init];
        webviewVC.url = URL;
        [self.nav pushViewController:webviewVC animated:YES];
    }
    else
    {
        if (![URL host] && ![URL path])
        {
            
            // possibly a local anchor link
            NSString *fragment = [URL fragment];
            
            if (fragment)
            {
                [self.textView scrollToAnchorNamed:fragment animated:NO];
            }
        }
    }
}

- (void)imagePushed:(DTLinkButton *)button{
    
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
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[[button.URL absoluteURL] description] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open in Safari", nil), NSLocalizedString(@"Save Picture", nil), nil];
            sheet.tag = 100;
            [sheet showFromRect:button.frame inView:button.superview animated:YES];
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

#pragma mark - Utilities

- (void)replyActivity{
    
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    self.replyInput = [[CCTopicViewReplyInput alloc] initWithFrame:mainWindow.bounds];
    //NSLog(@"count %d", (int)CFGetRetainCount((__bridge CFTypeRef)self.replyInput));
    self.replyInput.post = self.post;
    self.replyInput.topic = self.topic;
    self.replyInput.rankInList = self.rankInList;
    @weakify(self);
    self.replyInput.dismissViewBlock = ^{
        @strongify(self);
        [self.replyInput removeFromSuperview];
        self.replyInput = nil;
    };
    [mainWindow addSubview:self.replyInput];
    //NSLog(@"count %d", (int)CFGetRetainCount((__bridge CFTypeRef)self.replyInput));
    [self.replyInput showView];
}

- (void)likeActivity{
    
    if (![CCDataManager sharedManager].user.isLogin) {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Need Login", nil) message:NSLocalizedString(@"You need login to vote this topic", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@[NSLocalizedString(@"Login", nil)] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
            }
        }];
        
        [alert show];
    }else if (self.post.postLiked){
        [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_info"] withText:NSLocalizedString(@"Do not like it again", nil)];
    }else{
        
        if (self.post.postID) {
            [CCHelper showBlackProgressHudWithText:NSLocalizedString(@"In requesting", nil)];
            [[CCDataManager sharedManager] actionForPost:[self.post.postID integerValue] actionType:CCPostActionTypeVote success:^(CCTopicPostModel *postModel) {
                
                self.post.postLiked = YES;
                self.praiseCountLabel.text = [NSString stringWithFormat:@"%d", (int)self.post.postLikeCount+1];
                
                [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Liked", nil)];
                
            } failure:^(NSError *error) {
                
                [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_error"] withText:NSLocalizedString(@"Vote Failed", nil)];
                NSLog(@"%@", error.description);
            }];
        }
        
    }
}

- (void)bookmarkActivity{
    
    if (![CCDataManager sharedManager].user.isLogin) {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Need Login", nil) message:NSLocalizedString(@"You need login to collect this topic", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@[NSLocalizedString(@"Login", nil)] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
            }
        }];
        
        [alert show];
    }else if (self.post.postBookmarked){
        [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_info"] withText:NSLocalizedString(@"Do not bookmark it again", nil)];
    }else{
        if (self.post) {
            [CCHelper showBlackProgressHudWithText:NSLocalizedString(@"In requesting", nil)];
            @weakify(self);
            [[CCDataManager sharedManager] bookmarkPost:[self.post.postID integerValue] success:^(BOOL collectStatus) {
                @strongify(self);
                self.post.postBookmarked = YES;
                
                [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Bookmarked", nil)];
            } failure:^(NSError *error) {
                [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_error"] withText:NSLocalizedString(@"Bookmark Failed", nil)];
                NSLog(@"%@", error.description);
            }];
            
        }
        
    }
}


#pragma mark - Public Method

- (void)showActionSheet{
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    sheet.tag = 200;
    [sheet addButtonWithTitle:NSLocalizedString(@"Reply", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"Vote", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"Bookmark", nil)];
    // Bug - the editor view that pushed from keywindow would be dismissed with actionsheet
    // so you should push editor view after actionsheet dismissed
    sheet.bk_didDismissBlock = ^(UIActionSheet *sheet, NSInteger buttonIndex){
        
        switch (buttonIndex) {
            case 1:
                [self replyActivity];
                break;
            case 2:
                [self likeActivity];
                break;
            case 3:
                [self bookmarkActivity];
                break;
                
            default:
                break;
        }
        
    };
    [sheet showInView:self.nav.view];

}

- (CGFloat)getCellHeight{
   
    self.cellHeight = [self.textView.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:kScreenWidth-55].height+60;
    
    return self.cellHeight;
}

@end
