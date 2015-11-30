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

#import <DTCoreText.h>
#import <DTAttributedTextView.h>
#import <DTLazyImageView.h>
#import <DTTiledLayerWithoutFade.h>
#import <QuartzCore/QuartzCore.h>

#import "SCCircularRefreshView.h"

#import "HTMLParser.h"

// dstatic const CGFloat kBodyFontSize = 16.0;

@interface CCTopicBodyCell() <IDMPhotoBrowserDelegate, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) DTAttributedTextView *bodyLabel;

@property (nonatomic, strong) UIView *border;

@property (nonatomic, assign) NSInteger bodyHeight;

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *imageButtonArray;
@property (nonatomic, strong) NSMutableArray *imageUrls;

@property (nonatomic, strong) NSURL *lastActionLink;
@property (nonatomic, strong) UIImage *lastActionImage;

@end

@implementation CCTopicBodyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhite;
        
        self.imageArray = [NSMutableArray array];
        self.imageButtonArray = [NSMutableArray array];
        self.imageUrls = [NSMutableArray array];
        
        self.bodyLabel = [self createAttributedTextView];

        @weakify(self);
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            @strongify(self);
            self.backgroundColor = kBackgroundColorWhite;
            
        }];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.border.frame = CGRectMake(10.0, self.height - 0.5, kScreenWidth - 20, 0.5);
    
}

- (void)layoutContent{
    CCTopicPostModel *post = self.topic.posts.count > 0 ? self.topic.posts[0] : nil;
    if (post && post.postContent.length > 0) {

        post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"<h2></h2>" withString:@""];

        
        // example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
        void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
            
            // the block is being called for an entire paragraph, so we check the individual elements
            
            for (DTHTMLElement *oneChildElement in element.childNodes)
            {

                //if an element is larger than twice the font size put it in it's own block
                if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
                {
                    oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
                    oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
                    oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
                }
            }
        };
        
        DTCSSStylesheet *css = [[DTCSSStylesheet alloc] initWithStyleBlock:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"topic" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil]];
        
        
        
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:CGSizeMake(kScreenWidth, CGFLOAT_MAX)], DTMaxImageSize,
                                        @"Arial", DTDefaultFontFamily, @"blue", DTDefaultLinkHighlightColor, callBackBlock, DTWillFlushBlockCallBack, css, DTDefaultStyleSheet, kFontColorBlackDark, DTDefaultTextColor, nil];
        [options setObject:[NSURL URLWithString:@"http://cocode.cc"] forKey:NSBaseURLDocumentOption];
        
        self.bodyLabel.attributedString = [[NSAttributedString alloc] initWithHTMLData:[post.postContent dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil];
        
        
        self.bodyLabel.frame = CGRectMake(10.0, 5.0, kScreenWidth-20.0, [self getCellHeight]);

//TODO clear
//        HTMLParser *parser = [[HTMLParser alloc] initWithData:[post.postContent dataUsingEncoding:NSUTF8StringEncoding] error:nil];
//        HTMLNode *body = [parser body];
//        NSString *string = [body rawContents];
//        NSArray *imageNodes = [body findChildrenWithAttribute:@"class" matchingName:@"lightbox-wrapper" allowPartial:YES];
//        NSMutableArray *tempImgAttachArray = [NSMutableArray array];
//        for (HTMLNode *lightBoxNode in imageNodes) {
//            HTMLNode *link = [lightBoxNode findChildTag:@"a"];
//            NSURL *defaultUrl = [NSURL URLWithString:[[lightBoxNode findChildTag:@"img"] getAttributeNamed:@"src"]];
//            NSLog(@"%@", defaultUrl.absoluteString);
//        }
        
    }

    
    
}

#pragma mark - Setter

- (void)setTopic:(CCTopicModel *)topic{
    _topic = topic;

    [self layoutContent];
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

- (DTAttributedTextView *)createAttributedTextView{
    DTAttributedTextView *textView = [[DTAttributedTextView alloc] initWithFrame:CGRectZero];
    
    textView.backgroundColor = [UIColor clearColor];
    //textView.textColor = kFontColorBlackDark;
    //textView.font = [UIFont systemFontOfSize:kBodyFontSize];
    textView.scrollEnabled = NO;
    //textView.editable = NO;
    
    
//    textView.linkTextAttributes = @{NSBackgroundColorAttributeName:kColorPurple, NSForegroundColorAttributeName:kColorPurple, NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleNone], NSUnderlineColorAttributeName:[UIColor clearColor]};
    textView.textDelegate = self;
    textView.shouldDrawImages = NO;
    textView.attributedTextContentView.shouldLayoutCustomSubviews = YES;
    textView.shouldDrawLinks = NO;
    
    [self addSubview:textView];
    
    
    return textView;
    
}

#pragma mark - DT delegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame{
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
    
    NSURL *URL = [attributes objectForKey:DTLinkAttribute];
    NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
    
    
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = URL;
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
    
    // demonstrate combination with long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
    //[button addGestureRecognizer:longPress];
    
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
            [self.imageUrls addObject:imageView.url];
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
    else if ([attachment isKindOfClass:[DTObjectTextAttachment class]])
    {
        // somecolorparameter has a HTML color
        NSString *colorName = [attachment.attributes objectForKey:@"#000"];
        UIColor *someColor = DTColorCreateWithHTMLName(colorName);
        
        UIView *someView = [[UIView alloc] initWithFrame:frame];
        someView.backgroundColor = someColor;
        someView.layer.borderWidth = 1;
        someView.layer.borderColor = [UIColor blackColor].CGColor;
        
        someView.accessibilityLabel = colorName;
        someView.isAccessibilityElement = YES;
        
        return someView;
    }
    
    return nil;
}

- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame{
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame,1,1) cornerRadius:10];
    
    CGColorRef color = [textBlock.backgroundColor CGColor];
    if (color)
    {
        CGContextSetFillColorWithColor(context, color);
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextFillPath(context);
        
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        CGContextStrokePath(context);
        return NO;
    }
    
    return YES; // draw standard background
}

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
        
        [AppDelegate.window.rootViewController presentViewController:browser animated:YES completion:nil];
        return YES;
    }
    
    if ([app canOpenURL:URL]) {
        [app openURL:URL];
        
        return YES;
    }
    return NO;
}

#pragma mark - DTLazyImageViewDelegate

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    
    NSLog(@"resize");
    
    NSURL *url = lazyImageView.url;
    
    CGSize imageSize = size;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    
    BOOL didUpdate = NO;
    
    // update all attachments that matchin this URL (possibly multiple images with same size)
    for (DTTextAttachment *oneAttachment in [self.bodyLabel.attributedTextContentView.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            
            didUpdate = YES;
        }
    }
    
    if (didUpdate)
    {
        // layout might have changed due to image sizes
        [self.bodyLabel relayoutText];
    }
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
                [self.bodyLabel scrollToAnchorNamed:fragment animated:NO];
            }
        }
    }
}

- (void)imagePushed:(DTLinkButton *)button
{
    
    NSArray *photos = [IDMPhoto photosWithURLs:_imageUrls];
    
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:self.nav.view];
    browser.delegate = self;
    browser.displayActionButton = NO;
    browser.displayArrowButton = NO;
    browser.displayCounterLabel = YES;
    [browser setInitialPageIndex:0];
    
    [AppDelegate.window.rootViewController presentViewController:browser animated:YES completion:nil];
    
//    NSURL *URL = button.URL;
//
//    if ([[UIApplication sharedApplication] canOpenURL:[URL absoluteURL]])
//    {
//        [[UIApplication sharedApplication] openURL:[URL absoluteURL]];
//    }
//    else
//    {
//        if (![URL host] && ![URL path])
//        {
//            
//            // possibly a local anchor link
//            NSString *fragment = [URL fragment];
//            
//            if (fragment)
//            {
//                [self.bodyLabel scrollToAnchorNamed:fragment animated:NO];
//            }
//        }
//    }
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


#pragma mark - Public Class Method

- (CGFloat)getCellHeight{

    return [self.bodyLabel.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:kScreenWidth-20].height+20;

}

@end
