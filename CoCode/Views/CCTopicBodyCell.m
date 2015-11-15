//
//  CCTopicBodyCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicBodyCell.h"

#import <TTTAttributedLabel.h>
#import <IDMPhotoBrowser.h>
#import <AnimatedGIFImageSerialization.h>
#import "SCQuote.h"
#import "CCTopicPostModel.h"

static const CGFloat kBodyFontSize = 16.0;

@interface CCTopicBodyCell() <TTTAttributedLabelDelegate, IDMPhotoBrowserDelegate, UIWebViewDelegate>

@property (nonatomic, strong) TTTAttributedLabel *bodyLabel;
@property (nonatomic, strong) UILabel *webView;

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
        
        self.bodyLabel = [self createAttributedLabel];
        
        
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //TODO
    CCTopicModel *topic = self.topic;
    
    //CCTopicPostModel *post = self.topic.posts[0];
    //self.bodyLabel.attributedText = [[NSAttributedString alloc] initWithString:post.postContent attributes:nil];
    self.border.frame = CGRectMake(10.0, self.height - 0.5, kScreenWidth - 20, 0.5);
    [self layoutContent];
}

- (void)layoutContent{
    CCTopicPostModel *post = self.topic.posts.count > 0 ? self.topic.posts[0] : nil;
    if (post && post.postContent.length > 0) {
        self.bodyLabel.text = [[NSAttributedString alloc] initWithData:[post.postContent dataUsingEncoding:NSUTF8StringEncoding] options:nil documentAttributes:nil error:nil];
        self.bodyHeight = [TTTAttributedLabel sizeThatFitsAttributedString:[[NSAttributedString alloc] initWithString:post.postContent] withConstraints:CGSizeMake(kScreenWidth-20, 0.0) limitedToNumberOfLines:0].height;
        if (!self.bodyLabel.attributedText.length) {
            self.bodyHeight = 0;
        }
        self.bodyLabel.frame = CGRectMake(10.0, 5.0, kScreenWidth-20.0, 200.0);
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

- (TTTAttributedLabel *)createAttributedLabel{
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kFontColorBlackDark;
    label.font = [UIFont systemFontOfSize:kBodyFontSize];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.delegate = self;
    [self addSubview:label];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8.0;
    
    label.linkAttributes = @{NSForegroundColorAttributeName:kFontColorBlackBlue, NSFontAttributeName:[UIFont systemFontOfSize:kBodyFontSize], NSParagraphStyleAttributeName:style};
    
    label.activeLinkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName:[NSNumber numberWithBool:NO], NSForegroundColorAttributeName:kBackgroundColorWhite, (NSString *)kTTTBackgroundFillColorAttributeName:(__bridge id)[kColorPurple CGColor], (NSString *)kTTTBackgroundCornerRadiusAttributeName:[NSNumber numberWithFloat:4.0]};
    
    [self.attributedLabelArray addObject:label];
    
    return label;
    
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    
}


#pragma mark - Public Class Method

+ (CGFloat)getCellHeightWithTopicModel:(CCTopicModel *)topic{
    
    return 600;
}

@end
