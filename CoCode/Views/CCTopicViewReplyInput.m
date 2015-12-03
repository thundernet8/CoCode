//
//  CCTopicViewReplyInput.m
//  CoCode
//
//  Created by wuxueqian on 15/12/1.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCTopicViewReplyInput.h"
#import "CCDataManager.h"

static CGFloat const kInputBackViewHeight = 180.0;
static NSInteger const kInputTextMinLength = 10;

@interface CCTopicViewReplyInput() <UITextViewDelegate>

#ifdef __IPHONE_8_0
@property (nonatomic, strong) UIVisualEffectView *blurBackgroundBar;
#else
@property (nonatomic, strong) UIView *blurBackgroundBar;
#endif
@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UIView *inputBackView;
@property (nonatomic, strong) UITextView *inputView;

@property (nonatomic, assign) BOOL isSubmitting;

@end

@implementation CCTopicViewReplyInput

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *contentView;
#ifdef __IPHONE_8_0
        self.blurBackgroundBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        contentView = self.blurBackgroundBar.contentView;
#else
        self.blurBackgroundBar = [[UIView alloc] init];
        contentView = self.blurBackgroundBar;
#endif
        self.hidden = YES;
        [self addSubview:self.blurBackgroundBar];
        
        self.backgroundButton = [[UIButton alloc] init];
        [contentView addSubview:self.backgroundButton];
        
        self.inputBackView = [[UIView alloc] init];
        self.inputBackView.backgroundColor = kBackgroundColorWhiteDark;
        [contentView addSubview:self.inputBackView];
        
        self.cancelButton = [[UIButton alloc] init];
        [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:kFontColorBlackDark forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        self.cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.inputBackView addSubview:self.cancelButton];
        
        self.submitButton = [[UIButton alloc] init];
        [self.submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
        [self.submitButton setTitleColor:kFontColorBlackDark forState:UIControlStateNormal];
        [self.submitButton setTitleColor:kFontColorBlackLight forState:UIControlStateDisabled];
        [self.submitButton setEnabled:NO];
        self.submitButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        self.submitButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.submitButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.inputBackView addSubview:self.submitButton];
        
        self.centerLabel = [[UILabel alloc] init];
        self.centerLabel.text = NSLocalizedString(@"Write a reply", nil);
        self.centerLabel.textColor = kFontColorBlackDark;
        self.centerLabel.textAlignment = NSTextAlignmentCenter;
        self.centerLabel.font = [UIFont systemFontOfSize:18.0];
        [self.inputBackView addSubview:self.centerLabel];
        
        self.inputView = [[UITextView alloc] init];
        self.inputView.delegate = self;
        self.inputView.backgroundColor = kBackgroundColorWhite;
        self.inputView.layer.borderWidth = 0.5;
        self.inputView.layer.borderColor = [UIColor grayColor].CGColor;
        self.inputView.font = [UIFont systemFontOfSize:14.0];
        [self.inputBackView addSubview:self.inputView];
        
        self.isSubmitting = NO;
        
        //Register keyboard notification
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)didMoveToSuperview{
    //handles
    @weakify(self);
    [self.backgroundButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self hiddenView];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.cancelButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self hiddenView];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.submitButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self submitReply];
    } forControlEvents:UIControlEventTouchUpInside];
    
    //layout
    self.blurBackgroundBar.frame = self.frame;
    self.backgroundButton.frame = self.frame;
    self.inputBackView.frame = CGRectMake(0, self.frame.origin.y+kScreenHeight-kInputBackViewHeight, kScreenWidth, 200.0);
    self.cancelButton.frame = CGRectMake(15.0, 15.0, 50.0, 25.0);
    self.centerLabel.frame = CGRectMake(60.0, 15.0, kScreenWidth-140, 25.0);
    self.submitButton.frame = CGRectMake(kScreenWidth-65, 15.0, 50.0, 25.0);
    
    self.inputView.frame = CGRectMake(15.0, 55.0, kScreenWidth-30, kInputBackViewHeight-75);
    
    [super didMoveToSuperview];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"dealloc");
}

#pragma mark - Show and Hidden

- (void)showView{
    self.hidden = NO;
    self.inputBackView.y = self.frame.origin.y+kScreenHeight-kInputBackViewHeight;
    [self.inputView becomeFirstResponder];
    
    //The animation is moved to keyboard notification selector to reach an synced animation between input view and keyboard
//    [UIView animateWithDuration:0.3 animations:^{
//        self.inputBackView.y = kScreenHeight-200-256;
//    } completion:^(BOOL finished) {
//        
//    }];

}

- (void)hiddenView{
    [self.inputView resignFirstResponder];
    @weakify(self);
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self);
        self.inputBackView.y = self.frame.origin.y+kScreenHeight;
    } completion:^(BOOL finished) {
        @strongify(self);
        self.hidden = YES;
        self.dismissViewBlock();
    }];
}

#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"begin edit");
}

- (void)textViewDidChange:(UITextView *)textView{
    self.submitButton.enabled = !(textView.text.length < kInputTextMinLength);
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"endedit");
}

#pragma mark - Submit Reply

- (void)submitReply{

    if (self.isSubmitting) {
        return;
    }
    self.isSubmitting = YES;
    
    [CCHelper showBlackProgressHudWithText:NSLocalizedString(@"Submitting the reply...", nil)];
    
    @weakify(self);
    [[CCDataManager sharedManager] submitReplyWithContent:self.inputView.text toTopic:self.topic replyNested:YES success:^(CCTopicPostModel *postModel) {
        @strongify(self);
        self.isSubmitting = NO;
        [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Reply submitted successfully", nil)];
        [self hiddenView];
        
    } failure:^(NSError *error) {
        [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_error"] withText:NSLocalizedString(@"Reply failed", nil)];
        self.isSubmitting = NO;
        NSLog(@"%@", error.localizedDescription);
    }];
    
}

- (void)cancelSubmit{
    
}

#pragma mark - Selector

- (void)keyboardWillShow:(NSNotification *)notification{
    
    CGSize keyboardSize = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.inputBackView.y = kScreenHeight-kInputBackViewHeight-keyboardSize.height;
    } completion:^(BOOL finished) {
        
    }];
    [UIView commitAnimations];
}

- (void)keyboardDidShow:(NSNotification *)notification{
    
}

- (void)keyboardWillHide:(NSNotification *)notification{
    
}

- (void)keyboardDidHide:(NSNotification *)notification{
    
}

@end

