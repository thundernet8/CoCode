//
//  CCMemberPostListCell.m
//  CoCode
//
//  Created by wuxueqian on 15/12/5.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMemberPostListCell.h"

@interface CCMemberPostListCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *replyLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *separatorLine;

@end

@implementation CCMemberPostListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kCellHighlightedColor;
        
        self.separatorLine = [[UIView alloc] init];
        self.separatorLine.backgroundColor = kSeparatorColor;
        [self addSubview:self.separatorLine];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.titleLabel.textColor = kFontColorBlackDark;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [self addSubview:self.titleLabel];
        
        self.replyLabel = [[UILabel alloc] init];
        self.replyLabel.numberOfLines = 0;
        self.replyLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.replyLabel.textColor = kFontColorBlackLight;
        self.replyLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.replyLabel];
        
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
        self.replyLabel.textColor = kFontColorBlackLight;
        self.timeLabel.textColor = kFontColorBlackDark;
    }];
    
    return self;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    self.titleLabel.text = self.post.title;
    self.replyLabel.text = self.post.postContent;
    self.timeLabel.text = [CCHelper timeShortIntervalStringWithDate:self.post.postCreatedTime];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat titleHeight = [CCHelper getTextHeightWithText:self.post.title Font:[UIFont boldSystemFontOfSize:16.0] Width:kScreenWidth-80];
    CGFloat contentHeight = [CCHelper getTextHeightWithText:self.post.postContent Font:[UIFont systemFontOfSize:14.0] Width:kScreenWidth-20];
    
    self.titleLabel.frame = CGRectMake(10.0, 10.0, kScreenWidth-80, titleHeight);
    self.replyLabel.frame = CGRectMake(10.0, 10.0+titleHeight+5, kScreenWidth-20, contentHeight);
    self.timeLabel.frame = CGRectMake(kScreenWidth-70, 10.0, 60.0, 20.0);
    self.separatorLine.frame = CGRectMake(0, titleHeight+contentHeight+25, kScreenWidth, 0.5);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc");
}

#pragma mark - Utilities

#pragma mark - Publish Method

+ (CGFloat)getCellHeightWithPostModel:(CCTopicPostModel *)model{
    
    CGFloat titleHeight = [CCHelper getTextHeightWithText:model.title Font:[UIFont boldSystemFontOfSize:16.0] Width:kScreenWidth-80];
    CGFloat contentHeight = [CCHelper getTextHeightWithText:model.postContent Font:[UIFont systemFontOfSize:14.0] Width:kScreenWidth-20];
    
    return titleHeight+contentHeight+25;
}


@end
