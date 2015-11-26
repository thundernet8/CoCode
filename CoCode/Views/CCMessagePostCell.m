//
//  CCMessagePostCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMessagePostCell.h"

static NSString * const kLastPostTimeStamp = @"LastPostTimeStamp";
static NSInteger const kMinTimeDiff = 60; // s , for judge if need display time label
static NSInteger const kAvatarHeight = 40;
static UIEdgeInsets padding = {5, 5, 5, 5};

@interface CCMessagePostCell()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic) CGFloat timeLabelWidth;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic) CGFloat contentLabelHeight;

@property (nonatomic) BOOL isMe;
@property (nonatomic) BOOL needDisplayTime;

@end

@implementation CCMessagePostCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhiteDark;
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 20.0)];
        self.timeLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.200];
        self.timeLabel.textColor = [UIColor colorWithWhite:0.918 alpha:1.000];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.font = [UIFont systemFontOfSize:12.0];
        self.timeLabel.layer.cornerRadius = 3.0;
        //[self addSubview:self.timeLabel];
        
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.layer.cornerRadius = 5.0;
        self.avatarImageView.clipsToBounds = YES;
        [self addSubview:self.avatarImageView];
        
        self.avatarButton = [[UIButton alloc] init];
        [self addSubview:self.avatarButton];
        
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.backgroundColor = kCellHighlightedColor;
        self.contentLabel.textColor = kFontColorBlackDark;
        self.contentLabel.font = [UIFont systemFontOfSize:15.0];
        
        self.contentLabel.layer.cornerRadius = 5.0;
        [self addSubview:self.contentLabel];
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            self.backgroundColor = kCellHighlightedColor;
        }];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat timeLabelHeight = 0.0;
    if (self.needDisplayTime) {
        timeLabelHeight = 25.0;
    }
    
    self.timeLabel.frame = CGRectMake(kScreenWidth/2.0-self.timeLabelWidth/2.0, 5.0, self.timeLabelWidth, 20.0);
    
    if (self.isMe) {
        self.avatarImageView.frame = CGRectMake(kScreenWidth-kAvatarHeight-10, timeLabelHeight+5, kAvatarHeight, kAvatarHeight);
        self.contentLabel.frame = CGRectMake(10.0, timeLabelHeight+5, kScreenWidth-10-kAvatarHeight-10-10, self.contentLabelHeight);
    }else{
       self.avatarImageView.frame = CGRectMake(10, timeLabelHeight+5, kAvatarHeight, kAvatarHeight);
        self.contentLabel.frame = CGRectMake(10.0+kAvatarHeight+10, timeLabelHeight+5, kScreenWidth-10-kAvatarHeight-10-10, self.contentLabelHeight);
    }
}


- (CCMessagePostCell *)configureWithMessagePost:(CCTopicPostModel *)post{
    
    //Time label
    NSInteger nowTimestamp = [[NSDate date] timeIntervalSince1970];
    NSInteger lastTimestamp = [kUserDefaults objectForKey:kLastPostTimeStamp] ? [[kUserDefaults objectForKey:kLastPostTimeStamp] integerValue] : 0;
    if (nowTimestamp - lastTimestamp > kMinTimeDiff) {
        self.needDisplayTime = YES;
        self.timeLabel.text = [CCHelper timeDetailedIntervalStringWithDate:post.postCreatedTime];
        self.timeLabelWidth = [self.timeLabel sizeThatFits:CGSizeMake(kScreenWidth, 20.0)].width + 8;
        [self addSubview:self.timeLabel];
    }
    [kUserDefaults setObject:[NSNumber numberWithInteger:nowTimestamp] forKey:kLastPostTimeStamp];
    
    //Avatar
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:post.postUserAvatar] placeholderImage:[UIImage imageNamed:@"default_avatar_3"]];
    
    self.isMe = post.postYours; //TODO 聊天气泡
    
    //Content
    self.contentLabel.attributedText = [[NSAttributedString alloc] initWithData:[post.postContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.contentLabel.font = [UIFont systemFontOfSize:15.0];
    self.contentLabel.textColor = kFontColorBlackDark;
    self.contentLabelHeight = [self.contentLabel sizeThatFits:CGSizeMake(kScreenWidth-10-kAvatarHeight-10-10, CGFLOAT_MAX)].height+8;
    return self;
}

+ (CGFloat)getCellHeightWithMessagePost:(CCTopicPostModel *)post{
    
    return 100.0; //TODO clear
}

@end
