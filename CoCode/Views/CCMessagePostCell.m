//
//  CCMessagePostCell.m
//  CoCode
//
//  Created by wuxueqian on 15/11/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMessagePostCell.h"

@interface CCMessagePostCell()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation CCMessagePostCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 20.0)];
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            self.backgroundColor = kCellHighlightedColor;
        }];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    
}


- (CCMessagePostCell *)configureWithMessagePost:(CCTopicPostModel *)post{
    
    self.textLabel.text = post.postContent;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:post.postUserAvatar]];

    return self;
}

+ (CGFloat)getCellHeightWithMessagePost:(CCTopicPostModel *)post{
    
    return 100.0; //TODO clear
}

@end
