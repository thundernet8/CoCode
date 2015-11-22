//
//  CCTopicListCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicListCell.h"
#import "CCTopicModel.h"
#import "CCHelper.h"

static CGFloat const kAvatarHeight = 30.0;
static CGFloat const kTitleFontSize = 18.0;
#define kTitleLabelWidth (kScreenWidth - 56.0)

@interface CCTopicListCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton *avatarButton; //TODO 点击跳转个人资料页
@property (nonatomic, strong) UIButton *categoryButton;
@property (nonatomic, strong) UILabel *leftMetaLabel; //Author and Time
@property (nonatomic, strong) UILabel *rightMetaLabel; //Category, Views, Comments
@property (nonatomic, strong) UIImageView *stickImageView;

@property (nonatomic ,strong) UIView *separatorLine; //Separator line for tableview

@property (nonatomic, assign) NSInteger titleHeight;

@end

@implementation CCTopicListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhite; // Based on theme
        
        self.stickImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_top"]];
        self.stickImageView.clipsToBounds = YES;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = kFontColorBlackDark; // Based on theme
        self.titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self addSubview:self.titleLabel];
        
        self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_avatar"]];
        self.avatarImageView.layer.cornerRadius = kAvatarHeight/2.0;
        self.avatarImageView.clipsToBounds = YES;
        [self addSubview:self.avatarImageView];
        
        self.leftMetaLabel = [[UILabel alloc] init];
        self.leftMetaLabel.backgroundColor = [UIColor clearColor];
        self.leftMetaLabel.textColor = [UIColor  grayColor];
        self.leftMetaLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.leftMetaLabel];
        
        self.rightMetaLabel = [[UILabel alloc] init];
        self.rightMetaLabel.backgroundColor = [UIColor clearColor];
        self.rightMetaLabel.textColor = [UIColor  grayColor];
        self.rightMetaLabel.font = [UIFont systemFontOfSize:12.0];
        self.rightMetaLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.rightMetaLabel];
        
        self.separatorLine = [[UIView alloc] init];
        self.separatorLine.backgroundColor = kSeparatorColor;
        [self addSubview:self.separatorLine];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (_topic.isPinned) {
        [self addSubview:self.stickImageView];
        self.stickImageView.frame = CGRectMake(10.0, 19.0, 30.0, 15.0);
        self.titleLabel.frame = CGRectMake(45.0, 15.0, kTitleLabelWidth-35, self.titleHeight);

    }else{
        if ([self.subviews containsObject:self.stickImageView]) {
            [self.stickImageView removeFromSuperview];
        }
        self.titleLabel.frame = CGRectMake(10.0, 15.0, kTitleLabelWidth, self.titleHeight);
    }

    
    self.avatarImageView.frame = CGRectMake(kScreenWidth-10-kAvatarHeight, 15.0, kAvatarHeight, kAvatarHeight);
    self.avatarButton.frame = CGRectMake(kScreenWidth-kAvatarHeight-20, 0.0, kAvatarHeight+20, kAvatarHeight+20);
    
    //self.avatarImageView.centerY = self.height/2.0;
    self.avatarButton.centerY = self.height/2.0;
    
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme; // Based on theme
    
    self.leftMetaLabel.frame = CGRectMake(10.0, 25+self.titleHeight, kScreenWidth*0.68-10, 20.0);
    
    self.rightMetaLabel.frame = CGRectMake(kScreenWidth*0.68, 25+self.titleHeight, kScreenWidth*0.32-10, 20.0);
    
    self.separatorLine.frame = CGRectMake(0.0, self.titleHeight+49.0, kScreenWidth, 1.0);
}

- (void)isUnderCategory:(BOOL)inCategory{
    _inCategory = inCategory;
}

- (void)setTopic:(CCTopicModel *)topic{
    _topic = topic;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:topic.topicAuthorAvatar] placeholderImage:[UIImage imageNamed:@"default_avatar_2"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            self.avatarImageView.image = [UIImage imageNamed:@"default_avatar_2"];
        }
    }];
    
    self.titleLabel.text = topic.topicTitle;
    self.titleHeight = [CCHelper getTextHeightWithText:topic.topicTitle Font:[UIFont boldSystemFontOfSize:kTitleFontSize] Width:kTitleLabelWidth] + 2;
    
    NSString *dateString = [CCHelper timeIntervalStringWithDate:topic.topicLastRepliedTime];
    
    
    NSString *catString;
    if (!_inCategory && topic.topicCategoryID.integerValue > 0) {
        NSDictionary *cat = [CCHelper getCategoryInfoFromPlistForID:topic.topicCategoryID];
        catString = [NSString stringWithFormat:@" · %@", [cat objectForKey:@"NAME"]];
    }else{
        catString = @"";
    }
    
    self.leftMetaLabel.text = [NSString stringWithFormat:@"%@ · %@%@", topic.topicLastReplier, dateString, catString];

    self.rightMetaLabel.text = [NSString stringWithFormat:@"%d %@   %d %@", topic.topicViews.intValue, NSLocalizedString(@"Views", @"TopicListCell meta-Views"), topic.topicPostsCount.intValue-1, NSLocalizedString(@"Replies", @"TopicListCell meta-Replies")];
    
}

+ (CGFloat)getCellHeightWithTopicModel:(CCTopicModel *)topic{
    NSInteger titleHeight = [CCHelper getTextHeightWithText:topic.topicTitle Font:[UIFont boldSystemFontOfSize:kTitleFontSize] Width:kTitleLabelWidth] + 2;
    if (topic.topicTitle.length > 0) {
        return titleHeight + 50.0;
    }
    return 0;
}


@end
