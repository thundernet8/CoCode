//
//  CCNotificationListCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCNotificationListCell.h"
#import "CCMessageModel.h"
#import "CCBadgeModel.h"

@interface CCNotificationListCell()

@property (nonatomic, strong) UIView *unreadMark;
@property (nonatomic, strong) UIImageView *typeIcon;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *separatorLine;

@end

@implementation CCNotificationListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.unreadMark = [[UIView alloc] init];
        self.unreadMark.clipsToBounds = YES;
        self.unreadMark.layer.cornerRadius = 4.0;
        [self addSubview:self.unreadMark];
        
        self.typeIcon = [[UIImageView alloc] init];
        self.typeIcon.clipsToBounds = YES;
        [self addSubview:self.typeIcon];
        
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = kFontColorBlackDark;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [self addSubview:self.titleLabel];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.textColor = kFontColorBlackDark;
        self.detailLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.detailLabel];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.textColor = kFontColorBlackLight;
        self.timeLabel.font = [UIFont systemFontOfSize:14.0];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.timeLabel];
        
        self.separatorLine = [[UIView alloc] init];
        self.separatorLine.backgroundColor = kSeparatorColor;
        [self addSubview:self.separatorLine];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.unreadMark.frame = CGRectMake(10.0, 12.0, 8.0, 8.0);
    self.typeIcon.frame = CGRectMake(24.0, 6.0, 20.0, 20.0);
    self.titleLabel.frame = CGRectMake(50.0, 6.0, kScreenWidth-24-60, 20.0);
    self.detailLabel.frame = CGRectMake(24.0, 30.0, kScreenWidth-34.0, 16.0);
    self.timeLabel.frame = CGRectMake(kScreenWidth-60.0, 6.0, 50.0, 20.0);
    self.separatorLine.frame = CGRectMake(24.0, self.height, kScreenWidth-24.0, 0.5);
}


- (CCNotificationListCell *)configureWithNotificationModel:(id)model{
    
    if ([model isKindOfClass:[CCMessageModel class]]) {
        CCMessageModel *message = (CCMessageModel *)model;
        self.titleLabel.text = message.topicTitle;
        self.detailLabel.text = message.topicTitle;
        
        self.timeLabel.text = [CCHelper timeIntervalStringWithDate:message.createdTime];
        
        self.unreadMark.backgroundColor = kColorPurple;
    }
    
    if ([model isKindOfClass:[CCBadgeModel class]]) {
        CCBadgeModel *badgeMsg = (CCBadgeModel *)model;
        self.titleLabel.text = badgeMsg.fullMessage;
        
        self.timeLabel.text = [CCHelper timeIntervalStringWithDate:badgeMsg.createdTime];
        
        self.unreadMark.backgroundColor = kColorPurple;
    }
    
    return self;
}

+ (CGFloat)getCellHeightWithNotificationType:(CCNotificationType)type{
    if (type == CCNotificationTypeMessage) {
        return 55.0;
    }
    if (type == CCNotificationTypeBadge) {
        return 36.0;
    }
    
    return 0;
}

@end
