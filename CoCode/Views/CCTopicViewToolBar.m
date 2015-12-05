//
//  CCTopicViewToolBar.m
//  CoCode
//
//  Created by wuxueqian on 15/12/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicViewToolBar.h"

@interface CCTopicViewToolBar()

@property (nonatomic, strong) UIView *borderLine;
@property (nonatomic, strong) UIButton *replyFieldFocusButton;
@property (nonatomic, strong) UIButton *replyListButton;
@property (nonatomic, strong) UIImageView *replyIcon;
@property (nonatomic, strong) UILabel *replyCountLabel;

@end

@implementation CCTopicViewToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = kBackgroundColorWhiteDark;
        
        self.borderLine = [[UIView alloc] init];
        self.borderLine.backgroundColor = kSeparatorColor;
        [self addSubview:self.borderLine];
        
        self.replyFieldFocusButton = [[UIButton alloc] init];
        [self.replyFieldFocusButton setTitle:NSLocalizedString(@"Post your comment", nil) forState:UIControlStateNormal];
        [self.replyFieldFocusButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.replyFieldFocusButton setTitleColor:kFontColorBlackLight forState:UIControlStateNormal];
        [self.replyFieldFocusButton setBackgroundColor:kCellHighlightedColor];
        self.replyFieldFocusButton.layer.cornerRadius = 17.0;
        [self addSubview:self.replyFieldFocusButton];
        
        self.replyListButton = [[UIButton alloc] init];
        [self addSubview:self.replyListButton];
        
        self.replyIcon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"icon_comment"] imageWithTintColor:kFontColorBlackLight]];
        self.replyIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.replyIcon];
        
        self.replyCountLabel = [[UILabel alloc] init];
        self.replyCountLabel.textColor = kFontColorBlackLight;
        self.replyCountLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.replyCountLabel];
        
        [self.replyListButton bk_addEventHandler:^(id sender) {
            self.showCommentsActionBlock();
        } forControlEvents:UIControlEventTouchUpInside];
        
        [self.replyFieldFocusButton bk_addEventHandler:^(id sender) {
            self.showCommentEditorActionBlock();
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)setModel:(CCTopicModel *)model{
    _model = model;
    
    self.replyCountLabel.text = [NSString stringWithFormat:@"%d", MAX(0, model.topicPostsCount.intValue-1)];
    [self setNeedsLayout];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.borderLine.frame = CGRectMake(0, 0, kScreenWidth, 0.5);
    
    CGFloat numLabelWidth = [CCHelper getTextWidthWithText:self.replyCountLabel.text Font:[UIFont systemFontOfSize:14.0] height:24.0];
    
    self.replyCountLabel.frame = CGRectMake(kScreenWidth-10-numLabelWidth-10, 10.0, numLabelWidth, 24.0);
    self.replyCountLabel.textAlignment = NSTextAlignmentCenter;
    
    self.replyIcon.frame = CGRectMake(kScreenWidth-10-numLabelWidth-10-20-5, 12.0, 20.0, 20.0);
    self.replyListButton.frame = CGRectMake(kScreenWidth-10-numLabelWidth-10-30, 10.0, 30+numLabelWidth, 24.0);
    
    self.replyFieldFocusButton.frame = CGRectMake(10.0, 5.0, kScreenWidth-30-30-numLabelWidth-10, 34.0);
    self.replyFieldFocusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.replyFieldFocusButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10.0, 0, 0);

}

#pragma mark - Utilities



@end
