//
//  CCMenuSectionCellView.m
//  CoCode
//
//  Created by wuxueqian on 15/11/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCMenuSectionCell.h"
#import <UIImage+FontAwesome.h>

static CGFloat const kCellHeight = 60;
static CGFloat const kFontSize = 16.0;

@interface CCMenuSectionCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *highlightedImage;

@property (nonatomic, strong) UILabel *badgeLabel;

@property (nonatomic, assign) BOOL cellHighlighted;

@end

@implementation CCMenuSectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        //Configure Cell Views
        [self configureViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.cellHighlighted = selected;
    } completion:nil];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (self.isSelected) {
        return;
    }
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.cellHighlighted = highlighted;
    } completion:nil];
}

- (void)setCellHighlighted:(BOOL)cellHighlighted{
    _cellHighlighted = cellHighlighted;
    
    if (cellHighlighted) {
        if (kSetting.theme == CCThemeNight) {
            self.titleLabel.textColor = kFontColorBlackMid;
            self.backgroundColor = kMenuCellHighlightedColor;
            self.iconView.image = self.normalImage;
        }else{
            self.titleLabel.textColor = kColorPurple;
            self.backgroundColor = kMenuCellHighlightedColor;
            self.iconView.image = self.highlightedImage;
        }
    }else{
        if (kSetting.theme == CCThemeNight) {
            self.titleLabel.textColor = kFontColorBlackMid;
            self.backgroundColor = [UIColor clearColor];
            self.iconView.image = self.normalImage;
        }else{
            self.titleLabel.textColor = kFontColorBlackMid;
            self.backgroundColor = [UIColor clearColor];
            self.iconView.image = self.normalImage;
        }
    }
}

#pragma mark - Layout

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.iconView.frame = CGRectMake(30.0, 21.0, 18.0, 18.0);
    self.titleLabel.frame = CGRectMake(85.0, 0.0, 100.0, self.height);
}

#pragma mark - Configure Views

- (void)configureViews{
    //Cell Icon
    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.iconView];
    
    //Cell Title
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = kFontColorBlackMid;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [self addSubview:self.titleLabel];
}

#pragma mark - Setter

- (void)setTitle:(NSString *)title{
    _title = title;
    
    self.titleLabel.text = self.title;
}

- (void)setIconName:(NSString *)iconName{
    _iconName = iconName;
    
    //NSString *highlightedImageName = [self.iconName stringByAppendingString:@"_highlighted"];
    //self.highlightedImage = [[UIImage imageNamed:self.iconName] imageWithTintColor:kColorBlue];
    self.highlightedImage = [UIImage imageWithIcon:self.iconName backgroundColor:[UIColor clearColor] iconColor:kColorPurple andSize:CGSizeMake(20.0, 20.0)];
    
    //self.normalImage = [[UIImage imageNamed:highlightedImageName] imageWithTintColor:kFontColorBlackMid];
    self.normalImage  = [UIImage imageWithIcon:self.iconName backgroundColor:[UIColor clearColor] iconColor:kFontColorBlackMid andSize:CGSizeMake(20.0, 20.0)];
    
    self.normalImage = self.normalImage.imageForCurrentTheme;
    self.iconView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    
}

- (void)setBadge:(NSString *)badge{
    _badge = badge;
    
    static const CGFloat kBadgeWidth = 6.0;
    
    if (!self.badgeLabel && badge) {
        self.badgeLabel = [[UILabel alloc] init];
        self.badgeLabel.backgroundColor = [UIColor redColor];
        self.badgeLabel.textColor = kWhiteColor;
        self.badgeLabel.hidden = YES;
        self.badgeLabel.font = [UIFont systemFontOfSize:5.0];
        self.badgeLabel.layer.cornerRadius = kBadgeWidth/2.0;
        self.badgeLabel.clipsToBounds = YES;
        [self addSubview:self.badgeLabel];
    }
    
    self.badgeLabel.hidden = !badge;
    
    self.badgeLabel.frame = CGRectMake(80.0, 10.0, kBadgeWidth, kBadgeWidth);
    self.badgeLabel.text = badge;
}

#pragma mark - Public Class Method

+ (CGFloat)getCellHeight{
    return kCellHeight;
}

@end
