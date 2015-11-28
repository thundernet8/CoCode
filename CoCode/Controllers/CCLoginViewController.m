//
//  CCLoginViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCLoginViewController.h"

#import "SVProgressHUD.h"
#import "CCDataManager.h"

#define kViewOffsetYNormal 60.0
#define kViewOffsetYEditing 20.0

@interface CCLoginViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UILabel *logoLabel;

@property (nonatomic, strong) UIView *loginView;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *goRegisterButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;
@property (nonatomic, strong) UIView *separatorLine;

@property (nonatomic, strong) UIView *registerView;
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *usernameField2;
@property (nonatomic, strong) UITextField *passwordField2;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *goLoginButton;


@property (nonatomic, strong) UIButton *githubLogin;

@property (nonatomic) BOOL isKeyboardShowing;
@property (nonatomic) BOOL isLogging;
@property (nonatomic) BOOL isRegistering;

@end

@implementation CCLoginViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.isKeyboardShowing = NO;
        self.isLogging = NO;
        self.isRegistering = NO;
        
        self.backgroundImageView = [[UIImageView alloc] init];
        self.cancelButton = [[UIButton alloc] init];
        self.logoLabel = [[UILabel alloc] init];
        
        self.loginView = [[UIView alloc] init];
        self.usernameField = [self createTextFieldWithPlaceHolder:NSLocalizedString(@"Email Address or Username", nil) secureText:NO];
        self.passwordField = [self createTextFieldWithPlaceHolder:NSLocalizedString(@"Your Password", nil) secureText:YES];
        self.loginButton = [[UIButton alloc] init];
        self.goRegisterButton = [[UIButton alloc] init];
        self.forgotPasswordButton = [[UIButton alloc] init];
        self.separatorLine = [[UIView alloc] init];
        
        self.registerView = [[UIView alloc] init];
        self.emailField = [self createTextFieldWithPlaceHolder:NSLocalizedString(@"Email Address", nil) secureText:NO];
        self.usernameField2 = [self createTextFieldWithPlaceHolder:NSLocalizedString(@"Your Username", nil) secureText:NO];
        self.passwordField2 = [self createTextFieldWithPlaceHolder:NSLocalizedString(@"Your Password", nil) secureText:YES];
        self.registerButton = [[UIButton alloc] init];
        self.goLoginButton = [[UIButton alloc] init];

        
        self.githubLogin = [[UIButton alloc] init];
    }
    
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self.view addSubview:self.backgroundImageView];
    [self.cancelButton setImage:[UIImage imageNamed:@"icon_cancel_black"] forState:UIControlStateNormal];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.logoLabel];
    
    [self.view addSubview:self.loginView];
    [self.loginView addSubview:self.usernameField];
    [self.loginView addSubview:self.passwordField];
    [self.loginView addSubview:self.loginButton];
    [self.loginView addSubview:self.goRegisterButton];
    [self.loginView addSubview:self.forgotPasswordButton];
    [self.loginView addSubview:self.separatorLine];
    
    //[self.view addSubview:self.registerView];
    [self.registerView addSubview:self.emailField];
    [self.registerView addSubview:self.usernameField2];
    [self.registerView addSubview:self.passwordField2];
    [self.registerView addSubview:self.goLoginButton];
    [self.registerView addSubview:self.registerButton];
    
    [self.view addSubview:self.githubLogin];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureButtons];
    
    [self configureTappingToHideKeyboard];
    
    [self configureTextFieldDelegate];
    
    //self.backgroundImageView.backgroundColor = kBackgroundColorWhiteDark;
    self.backgroundImageView.backgroundColor = [UIColor colorWithRed:0.941 green:0.945 blue:0.961 alpha:1.000];
    [self.cancelButton bk_addEventHandler:^(id sender) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.logoLabel.text = @"CoCode";
    self.logoLabel.font = [UIFont boldSystemFontOfSize:30.0];
    self.logoLabel.textColor = kBlackColor;
    
    self.separatorLine.backgroundColor = [UIColor colorWithWhite:0.800 alpha:1.000];
    
    self.view.backgroundColor = kWhiteColor;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.backgroundImageView.frame = self.view.frame;
    self.cancelButton.frame = CGRectMake(15.0, 36.0, 25.0, 25.0);
    self.loginView.frame = CGRectMake(0.0, 60.0, kScreenWidth, 400.0);//TODO
    self.registerView.frame = CGRectMake(0.0, 60.0, kScreenWidth, 450.0);//TODO
    self.githubLogin.frame = CGRectMake(kScreenWidth/2.0-25, kScreenHeight-50.0, 50.0, 50.0);
    
    self.logoLabel.frame = CGRectMake(kScreenWidth/2.0-60, 75.0, 120.0, 60.0);
    
    self.usernameField.frame = CGRectMake(20.0, 100.0, kScreenWidth-40, 50.0);

    self.passwordField.frame = CGRectMake(20.0, 155.0, kScreenWidth-40, 50.0);
    
    self.loginButton.frame = CGRectMake(20.0, 215.0, kScreenWidth-40, 45.0);
    
    self.goRegisterButton.frame = CGRectMake(kScreenWidth/2.0-100, 275.0, 80.0, 20.0);

    
    self.forgotPasswordButton.frame = CGRectMake(kScreenWidth/2.0+20, 275.0, 80.0, 20.0);
    
    self.separatorLine.frame = CGRectMake(kScreenWidth/2.0, 277.0, 1.0, 16.0);
    
    self.emailField.frame = CGRectMake(20.0, 100.0, kScreenWidth-40, 50.0);
    self.usernameField2.frame = CGRectMake(20.0, 155.0, kScreenWidth-40, 50.0);
    self.passwordField2.frame = CGRectMake(20.0, 210.0, kScreenWidth-40, 50.0);
    self.registerButton.frame = CGRectMake(20.0, 270.0, kScreenWidth-40, 45.0);
    
    self.goLoginButton.frame = CGRectMake(20.0, 330.0, kScreenWidth-40, 20.0);
    
}

#pragma mark - Configuration

- (void)configureTappingToHideKeyboard{
    void (^tapping)() = ^(){
        [self hideKeyboard];
    };
    [self.view bk_whenTapped:tapping];
//    [self.loginView bk_whenTapped:tapping];
//    [self.registerView bk_whenTapped:tapping];
}

- (void)configureButtons{
    self.loginButton.layer.cornerRadius = 5.0;
    self.loginButton.backgroundColor = kPurpleColor;
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [self.loginButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [self.loginButton bk_addEventHandler:^(id sender) {
        [self login];
    } forControlEvents:UIControlEventTouchUpInside];
    //self.loginButton.enabled = NO;
    
    
    [self.goRegisterButton setTitle:NSLocalizedString(@"Sign Up", nil) forState:UIControlStateNormal];
    self.goRegisterButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.goRegisterButton setTitleColor:kPurpleColor forState:UIControlStateNormal];
    [self.goRegisterButton bk_addEventHandler:^(id sender) {
//        [self.loginView removeFromSuperview];
//        [self.view addSubview:self.registerView];
//        self.isKeyboardShowing = NO;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cocode.cc/login"]];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.forgotPasswordButton setTitle:NSLocalizedString(@"Forgot Password?", nil) forState:UIControlStateNormal];
    self.forgotPasswordButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.forgotPasswordButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.forgotPasswordButton bk_addEventHandler:^(id sender) {
        [self forgotPassword];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.registerButton.layer.cornerRadius = 5.0;
    self.registerButton.backgroundColor = kPurpleColor;
    self.registerButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [self.registerButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    [self.registerButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [self.registerButton bk_addEventHandler:^(id sender) {
        [self registerCocode];
    } forControlEvents:UIControlEventTouchUpInside];
    self.registerButton.enabled = NO;
    
    [self.goLoginButton setTitle:NSLocalizedString(@"Sign In", nil) forState:UIControlStateNormal];
    self.goLoginButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.goLoginButton setTitleColor:kPurpleColor forState:UIControlStateNormal];
    [self.goLoginButton bk_addEventHandler:^(id sender) {
        [self.registerView removeFromSuperview];
        [self.view addSubview:self.loginView];
        self.isKeyboardShowing = NO;
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureTextFieldDelegate{
    @weakify(self);
    
    [self.usernameField setBk_shouldBeginEditingBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        [self showKeyboard];
        return YES;
    }];
    [self.emailField setBk_shouldBeginEditingBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        [self showKeyboard];
        return YES;
    }];
    [self.passwordField setBk_shouldBeginEditingBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        [self showKeyboard];
        return YES;
    }];
    [self.usernameField2 setBk_shouldBeginEditingBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        [self showKeyboard];
        return YES;
    }];
    [self.passwordField2 setBk_shouldBeginEditingBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        [self showKeyboard];
        return YES;
    }];
}

#pragma mark - Create TextField

- (UITextField *)createTextFieldWithPlaceHolder:(NSString *)placeholder secureText:(BOOL)isSecure{
    UITextField *textField = [[UITextField alloc] init];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.secureTextEntry = isSecure;
    textField.placeholder = placeholder;
    textField.backgroundColor = kWhiteColor;
    textField.layer.cornerRadius = 5.0;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 50.0)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    
    return textField;
}

#pragma mark - Handle Action

- (void)forgotPassword{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cocode.cc/login"]];
}

- (void)showKeyboard{
    if (self.isKeyboardShowing) {
        return;
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.logoLabel.y -= 36;
            if ([self.view.subviews containsObject:self.loginView]) {
                self.loginView.y = kViewOffsetYEditing;
                self.usernameField.y -= 10;
                self.passwordField.y -= 10;
                self.loginButton.y -= 10;
                self.goRegisterButton.y -= 10;
                self.forgotPasswordButton.y -= 10;
                self.separatorLine.y -= 10;
            }
            if ([self.view.subviews containsObject:self.registerView]) {
                self.registerView.y = kViewOffsetYEditing;
                self.emailField.y -= 20;
                self.usernameField2.y -= 20;
                self.passwordField2.y -= 20;
                self.registerButton.y -= 20;
                self.goLoginButton.y -= 20;
            }
        }];
        self.isKeyboardShowing = YES;
    }
}

- (void)hideKeyboard{
    if (self.isKeyboardShowing) {
        [self.view endEditing:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.logoLabel.y += 36;
            if ([self.view.subviews containsObject:self.loginView]) {
                self.loginView.y = kViewOffsetYNormal;
                self.usernameField.y += 10;
                self.passwordField.y += 10;
                self.loginButton.y += 10;
                self.goRegisterButton.y += 10;
                self.forgotPasswordButton.y += 10;
                self.separatorLine.y += 10;
                
            }
            if ([self.view.subviews containsObject:self.registerView]) {
                self.registerView.y = kViewOffsetYNormal;
                self.emailField.y += 20;
                self.usernameField2.y += 20;
                self.passwordField2.y += 20;
                self.registerButton.y += 20;
                self.goLoginButton.y += 20;
            }
        }];
        self.isKeyboardShowing = NO;
    }
}

- (void)login{
    if (self.isLogging) {
        return;
    }

    if (self.usernameField.text.length > 0 && self.passwordField.text.length > 0) {
        [self hideKeyboard];
        [CCHelper showBlackProgressHudWithText:@"登录中···"];
        
        [[CCDataManager sharedManager] loginWithUsername:self.usernameField.text password:self.passwordField.text success:^(id respondeObject) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:respondeObject];
            //[SVProgressHUD dismiss];
            [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Login success", nil)];
            [self endLogin];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            NSString *reasonString;
            if (error.code < 900) {
                reasonString = NSLocalizedString(@"Please check your network", nil);
            }else{
                reasonString = NSLocalizedString(@"Please check your input information", nil);
            }
            UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:NSLocalizedString(@"Login failed", nil) message:reasonString];
            [alert bk_setCancelButtonWithTitle:@"OK" handler:^{
                [self endLogin];
            }];
            [alert show];
        }];
    }
}

- (void)endLogin{
    self.usernameField.enabled = YES;
    self.passwordField.enabled = YES;
    
    //[self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    
    self.isLogging = NO;
}

//- (void)cancelLogin{
//    
//}
//
- (void)registerCocode{
    
}

@end
