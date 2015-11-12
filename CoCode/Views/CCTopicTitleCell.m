//
//  CCTopicTitleCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicTitleCell.h"

static const CGFloat kTitleFontSize = 18.0;

@interface CCTopicTitleCell()

@property (nonatomic, assign) NSInteger titleHeight;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CCTopicTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhite;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = kFontColorBlackDark;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:kTitleFontSize];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        [self addSubview:self.titleLabel];
    }
    
    return self;
}

#pragma mark - Setter

- (void)setTopic:(CCTopicModel *)topic{
    _topic = topic;
    
    self.titleLabel.text = topic.topicTitle;
    self.titleHeight = [CCHelper getTextHeightWithText:topic.topicTitle Font:[UIFont boldSystemFontOfSize:kTitleFontSize] Width:kScreenWidth-20];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(10.0, 15.0, kScreenWidth-20, self.titleHeight);
}

#pragma mark - Public Class Methods

+ (CGFloat)getCellHeightWithTopicModel:(CCTopicModel *)topic{
    NSInteger titleHeight = [CCHelper getTextHeightWithText:topic.topicTitle Font:[UIFont boldSystemFontOfSize:kTitleFontSize] Width:kScreenWidth-20];
    if (topic.topicTitle.length > 0) {
        return titleHeight + 25;
    }
    return 0;
}

@end
