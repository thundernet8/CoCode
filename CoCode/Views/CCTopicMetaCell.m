//
//  CCTopicMetaCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicMetaCell.h"
#import "CCProfileViewController.h"

static const CGFloat kAvatarHeight = 16.0;
static const CGFloat kNameFontSize = 14.0;
static const CGFloat kMetaFontSize = 12.0;

@interface CCTopicMetaCell()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton *avatarButton;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *rightMetaLabel; //Time and Reply count

@end

@implementation CCTopicMetaCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhite;
        
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.avatarImageView.layer.cornerRadius = kAvatarHeight/2.0;
        self.avatarImageView.clipsToBounds = YES;
        self.avatarImageView.size = CGSizeMake(kAvatarHeight, kAvatarHeight);
        //self.avatarImageView.image = [UIImage imageNamed:@"default_avatar"];
        [self addSubview:self.avatarImageView];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = kFontColorBlackBlue;
        self.nameLabel.font = [UIFont boldSystemFontOfSize:kNameFontSize];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.clipsToBounds = YES;
        [self addSubview:self.nameLabel];
        
        self.rightMetaLabel = [[UILabel alloc] init];
        self.rightMetaLabel.backgroundColor = [UIColor clearColor];
        self.rightMetaLabel.textColor = kFontColorBlackLight;
        self.rightMetaLabel.font = [UIFont systemFontOfSize:kMetaFontSize];
        self.rightMetaLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.rightMetaLabel];
        
        //Handles
        @weakify(self);
        [self.avatarButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            
            CCProfileViewController *profileViewController = [[CCProfileViewController alloc] init];
            profileViewController.member = self.topic.author;
            
            [self.nav pushViewController:profileViewController animated:YES];
            
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.avatarImageView.x = 10.0;
    self.avatarImageView.centerY = self.height/2;
    
    self.nameLabel.x = 10 + self.avatarImageView.width + 8;
    self.nameLabel.centerY = self.height/2;
    
    //self.rightMetaLabel.x = kScreenWidth - 10.0 - self.rightMetaLabel.width;
    self.rightMetaLabel.x = 10 + self.avatarImageView.width + 8 + self.nameLabel.width + 8;
    self.rightMetaLabel.centerY = self.height/2;
    
    self.avatarButton.frame = CGRectMake(0.0, 0.0, self.nameLabel.width + 10, self.height);
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    
    
}


#pragma mark - Setter

- (void)setTopic:(CCTopicModel *)topic{
    _topic = topic;

    BOOL isFirstSet = topic.posts.count > 0 ? NO : YES;
    
    if (isFirstSet) {
        return;
    }
    
    
    NSString *rightMeta = NSLocalizedString(@"Post at ", nil);
    //NSInteger replyCount = topic.posts.count - 1;
    
    rightMeta = [rightMeta stringByAppendingString:[CCHelper timeIntervalStringWithDate:topic.topicCreatedTime]];
//    if (replyCount > 0) {
//        rightMeta = [rightMeta stringByAppendingString:[NSString stringWithFormat:@" · %d %@", (int)replyCount, NSLocalizedString(@"Replies", nil)]];
//    }
    
    self.rightMetaLabel.text = rightMeta;
    [self.rightMetaLabel sizeToFit];
    
    self.nameLabel.text = topic.author.memberName && topic.author.memberName.length > 0 ? topic.author.memberName : topic.author.memberUserName;
    [self.nameLabel sizeToFit];
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:topic.author.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
}

#pragma mark - Public Class Methods

+ (CGFloat)getCellHeightWithTopicModel:(CCTopicModel *)topic{
    
    if (topic.topicTitle.length > 0) {
        return 28;
    }
    return 0;
}

@end
