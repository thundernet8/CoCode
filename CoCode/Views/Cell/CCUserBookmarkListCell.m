//
//  CCUserBookmarkListCell.m
//  CoCode
//
//  Created by wuxueqian on 15/12/5.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCUserBookmarkListCell.h"

static NSInteger const kAvatarHeight = 40;

@interface CCUserBookmarkListCell()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
//@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *authorNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *separatorLine;

@end

@implementation CCUserBookmarkListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kCellHighlightedColor;
        
        self.separatorLine = [[UIView alloc] init];
        self.separatorLine.backgroundColor = kSeparatorColor;
        [self addSubview:self.separatorLine];
        
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.clipsToBounds = YES;
        self.avatarImageView.layer.cornerRadius = kAvatarHeight/2.0;
        [self addSubview:self.avatarImageView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.titleLabel.textColor = kFontColorBlackDark;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [self addSubview:self.titleLabel];
        
        self.authorNameLabel = [[UILabel alloc] init];
        self.authorNameLabel.numberOfLines = 1;
        self.authorNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.authorNameLabel.textColor = kFontColorBlackLight;
        self.authorNameLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.authorNameLabel];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.textColor = kFontColorBlackDark;
        self.timeLabel.font = [UIFont systemFontOfSize:14.0];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.timeLabel];
    }
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        self.backgroundColor = kCellHighlightedColor;
        self.separatorLine.backgroundColor = kSeparatorColor;
        self.titleLabel.textColor = kFontColorBlackDark;
        self.authorNameLabel.textColor = kFontColorBlackLight;
        self.timeLabel.textColor = kFontColorBlackDark;
    }];
    
    return self;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    if (self.topic.topicAuthorAvatar.length) {
       [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.topic.topicAuthorAvatar] placeholderImage:[UIImage imageNamed:@"default_avatar_3"]];
    }else{
        self.avatarImageView.image = [UIImage imageNamed:@"default_avatar_3"];
    }
    
    self.titleLabel.text = self.topic.topicTitle;
    self.authorNameLabel.text = (self.topic.topicAuthorName!=(id)[NSNull null]&&self.topic.topicAuthorName.length)?self.topic.topicAuthorName:self.topic.topicAuthorUserName;
    self.timeLabel.text = [CCHelper timeShortIntervalStringWithDate:self.topic.topicCreatedTime];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat titleHeight = [CCHelper getTextHeightWithText:self.topic.topicTitle Font:[UIFont boldSystemFontOfSize:16.0] Width:kScreenWidth-80-kAvatarHeight-10];
    //CGFloat contentHeight = [CCHelper getTextHeightWithText:self.topic.topicContent Font:[UIFont systemFontOfSize:14.0] Width:kScreenWidth-20];
    self.avatarImageView.frame = CGRectMake(10.0, 10.0, kAvatarHeight, kAvatarHeight);
    self.titleLabel.frame = CGRectMake(10.0+kAvatarHeight+10, 10.0, kScreenWidth-70-kAvatarHeight-10, titleHeight);
    self.authorNameLabel.frame = CGRectMake(10.0+kAvatarHeight+10, 10.0+titleHeight+5, kScreenWidth-20-kAvatarHeight-10, 20);
    self.timeLabel.frame = CGRectMake(kScreenWidth-70, 10.0, 60.0, 20.0);
    self.separatorLine.frame = CGRectMake(0, MAX(kAvatarHeight, titleHeight+25)+20, kScreenWidth, 0.5);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc");
}

#pragma mark - Utilities

#pragma mark - Publish Method

+ (CGFloat)getCellHeightWithTopicModel:(CCTopicModel *)model{
    
    CGFloat titleHeight = [CCHelper getTextHeightWithText:model.topicTitle Font:[UIFont boldSystemFontOfSize:16.0] Width:kScreenWidth-80-kAvatarHeight-10];
    //CGFloat contentHeight = [CCHelper getTextHeightWithText:model.topicContent Font:[UIFont systemFontOfSize:14.0] Width:kScreenWidth-20];
    
    return MAX(kAvatarHeight, titleHeight+25)+20;
}

@end
