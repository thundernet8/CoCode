//
//  CCMessagePostCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMessagePostCell.h"
#import <DTCoreText.h>

static NSInteger const kAvatarHeight = 50;
static NSInteger const kFontSize = 15;

@interface CCMessagePostCell()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic) unsigned long timestamp;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) DTAttributedLabel *contentLabel;
@property (nonatomic) CGFloat contentLabelHeight;

@property (nonatomic) BOOL isMe;
@property (nonatomic) BOOL needTimeLabel;

@end

@implementation CCMessagePostCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhiteDark;
        self.contentView.clipsToBounds = YES;
        
        self.needTimeLabel = NO;
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 20.0)];
        self.timeLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.200];
        self.timeLabel.textColor = [UIColor colorWithWhite:0.918 alpha:1.000];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.font = [UIFont systemFontOfSize:12.0];
        self.timeLabel.layer.cornerRadius = 3.0;
        //[self addSubview:self.timeLabel];
        
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.layer.cornerRadius = kAvatarHeight/2.0;
        self.avatarImageView.clipsToBounds = YES;
        [self addSubview:self.avatarImageView];
        
        self.avatarButton = [[UIButton alloc] init];
        [self addSubview:self.avatarButton];
        
        self.contentLabel = [[DTAttributedLabel alloc] init];
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.contentLabel.backgroundColor = kCellHighlightedColor;
        self.contentLabel.tintColor = kFontColorBlackDark;
        self.contentLabel.edgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        self.contentLabel.layer.cornerRadius = 5.0;
        [self addSubview:self.contentLabel];
        
        
        @weakify(self);
        [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            @strongify(self);
            self.backgroundColor = kCellHighlightedColor;
        }];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    
}

- (CCMessagePostCell *)configureWithMessagePost:(CCTopicPostModel *)post needTimeLabel:(BOOL)needTimeLabel{
    
    NSLog(@"configure");
    
    //Time label

    if (needTimeLabel) {
        self.needTimeLabel = YES;
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
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:CGSizeMake(kScreenWidth, CGFLOAT_MAX)], DTMaxImageSize,
                                    @"Arial", DTDefaultFontFamily, @"blue", DTDefaultLinkHighlightColor, css, DTDefaultStyleSheet, kFontColorBlackDark, DTDefaultTextColor, [NSNumber numberWithInteger:kFontSize], DTDefaultFontSize, nil];
    [options setObject:[NSURL URLWithString:@"http://cocode.cc"] forKey:NSBaseURLDocumentOption];
    
    self.contentLabel.attributedString = [[NSAttributedString alloc] initWithHTMLData:[post.postContent dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil];
    
    
    CGFloat timeLabelHeight = 0.0;
    if (self.needTimeLabel) {
        timeLabelHeight = 25.0;
        CGFloat timeLabelWidth = [self.timeLabel sizeThatFits:CGSizeMake(kScreenWidth, 20.0)].width + 8;
        self.timeLabel.frame = CGRectMake(kScreenWidth/2.0-timeLabelWidth/2.0, 5.0, timeLabelWidth, timeLabelHeight-5);
    }
    
    
    if (self.isMe) {
        self.avatarImageView.frame = CGRectMake(kScreenWidth-kAvatarHeight-10, timeLabelHeight+5, kAvatarHeight, kAvatarHeight);
        self.contentLabel.frame = CGRectMake(10.0, timeLabelHeight+5, kScreenWidth-10-kAvatarHeight-10-10, [self getCellHeightOfAll:NO]);
    }else{
        self.avatarImageView.frame = CGRectMake(10, timeLabelHeight+5, kAvatarHeight, kAvatarHeight);
        self.contentLabel.frame = CGRectMake(10.0+kAvatarHeight+10, timeLabelHeight+5, kScreenWidth-10-kAvatarHeight-10-10, [self getCellHeightOfAll:NO]);
    }
    
}


- (CGFloat)getCellHeightOfAll:(BOOL)all{
    
    if (self.cellHeight&&all) {
        return self.cellHeight;
    }
    if (self.contentLabelHeight&&!all) {
        return self.contentLabelHeight;
    }
    
    self.contentLabelHeight = [self.contentLabel sizeThatFits:CGSizeMake(kScreenWidth-10-kAvatarHeight-10-10, CGFLOAT_MAX)].height+10;
    
    CGFloat timeLabelHeight = self.needTimeLabel ? 25.0:0;
    self.cellHeight = MAX(kAvatarHeight, self.contentLabelHeight) + timeLabelHeight + 20;
    
    NSLog(@"getCellHeight%f / %f", self.cellHeight, self.contentLabelHeight);
    
    return all?self.cellHeight:self.contentLabelHeight;

}

@end
