//
//  CCWebViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCWebViewController.h"
#import "SCCircularRefreshView.h"

@interface CCWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *noticeLabel;
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) UIButton *backwardButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) SCCircularRefreshView *refreshIconView;

@end

@implementation CCWebViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self configureNavi];
    [self configureWebview];
    [self configureToolbar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.webView.frame = CGRectMake(0, 64.0, kScreenWidth, kScreenHeight-64-45);
    self.noticeLabel.frame = CGRectMake(10.0, 75.0, kScreenWidth-20, 20.0);
    self.toolBar.frame = CGRectMake(0, kScreenHeight-45, kScreenWidth, 45.0);
    self.backwardButton.frame = CGRectMake(20.0, 10.0, 24.0, 24.0);
    self.forwardButton.frame = CGRectMake(kScreenWidth-44.0, 10.0, 24.0, 24.0);
    self.refreshIconView.frame = CGRectMake(kScreenWidth/2.0-12, 10.0, 24.0, 24.0);
    self.refreshIconView.loadingImageView.frame = CGRectMake(0, 0, 24.0, 24.0);
    self.refreshButton.frame = CGRectMake(kScreenWidth/2.0-12, 10.0, 24.0, 24.0);
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self loadContent];
}

#pragma mark - Configuration

- (void)configureNavi{
    
    @weakify(self);
    self.sc_navigationItem.leftBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationItem.rightBarButtonItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self shareActivity];
    }];
    
    self.sc_navigationItem.title = NSLocalizedString(@"Loading...", nil);
}

- (void)configureWebview{
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    self.backgroundView.backgroundColor = kBackgroundColorGray;
    [self.view addSubview:self.backgroundView];
    self.noticeLabel = [[UILabel alloc] init];
    self.noticeLabel.backgroundColor = [UIColor clearColor];
    self.noticeLabel.font = [UIFont systemFontOfSize:14.0];
    self.noticeLabel.numberOfLines = 1;
    self.noticeLabel.textAlignment = NSTextAlignmentCenter;
    self.noticeLabel.textColor = kFontColorBlackLight;
    [self.backgroundView addSubview:self.noticeLabel];
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.backgroundView addSubview:self.webView];
    
}

- (void)configureToolbar{
    
    self.toolBar = [[UIView alloc] init];
    self.toolBar.backgroundColor = kBackgroundColorWhite;
    [self.view addSubview:self.toolBar];
    
    self.backwardButton = [[UIButton alloc] init];
    self.backwardButton.enabled = NO;
    [self.backwardButton setImage:[UIImage imageNamed:@"icon_button_backward"] forState:UIControlStateNormal];
    [self.backwardButton setImage:[[UIImage imageNamed:@"icon_button_backward"] imageWithTintColor:[UIColor colorWithWhite:0.737 alpha:1.000]] forState:UIControlStateDisabled];
    [self.toolBar addSubview:self.backwardButton];
    
    self.forwardButton = [[UIButton alloc] init];
    self.forwardButton.enabled = NO;
    [self.forwardButton setImage:[UIImage imageNamed:@"icon_button_backward"] forState:UIControlStateNormal];
    [self.forwardButton setImage:[[UIImage imageNamed:@"icon_button_forward"] imageWithTintColor:[UIColor colorWithWhite:0.737 alpha:1.000]] forState:UIControlStateDisabled];
    [self.toolBar addSubview:self.forwardButton];
    
    self.refreshIconView = [[SCCircularRefreshView alloc] init];
    self.refreshIconView.loadingImageView.image = [UIImage imageNamed:@"icon_loading"];
    self.refreshIconView.loadingImageView.tintColor = [UIColor grayColor];
    [self.toolBar addSubview:self.refreshIconView];
    
    self.refreshButton = [[UIButton alloc] init];
    self.refreshButton.enabled = NO;
    [self.refreshButton setImage:[UIImage imageNamed:@"icon_button_refresh"] forState:UIControlStateNormal];
    [self.refreshButton setImage:[[UIImage imageNamed:@"icon_button_refresh"] imageWithTintColor:[UIColor clearColor]] forState:UIControlStateDisabled];
    [self.refreshButton bk_addEventHandler:^(id sender) {
        [self.webView reload];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:self.refreshButton];
    
    //toolbar top shadow
    self.toolBar.layer.masksToBounds = NO;
    self.toolBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.toolBar.layer.shadowOffset = CGSizeMake(0.0f, -1.0f);
    self.toolBar.layer.shadowOpacity = 0.2f;
    
}

#pragma mark - Webview Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    self.noticeLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Page appears by(left)", nil), webView.request.URL.absoluteString, NSLocalizedString(@"Page appears by(right)", nil)];
    
    self.backwardButton.enabled = webView.canGoBack;
    self.backwardButton.enabled = webView.canGoForward;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *title=[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.sc_navigationItem.title = title;
    
    NSString *readyState = [self.webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    if ([readyState isEqualToString:@"complete"]) {
        [self.refreshIconView endRefreshing];
        self.refreshIconView.alpha = 0;
        self.refreshButton.enabled = YES;
    }

    self.noticeLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Page appears by(left)", nil), webView.request.URL.host, NSLocalizedString(@"Page appears by(right)", nil)];
    
    self.backwardButton.enabled = webView.canGoBack;
    self.backwardButton.enabled = webView.canGoForward;

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    self.sc_navigationItem.title = @"";
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked && [@"#" rangeOfString:[request.URL.absoluteString stringByReplacingOccurrencesOfString:self.webView.request.mainDocumentURL.absoluteString withString:@""]].location != 0) {
        [self.webView loadRequest:request];
    }
    
    return YES;
}

#pragma mark - Utilities

- (void)shareActivity{
    
    if (self.webView.loading) {
        return;
    }
    
    //UIActivityViewController
    NSString *textToShare = self.sc_navigationItem.title;
    NSURL *urlToShare = self.webView.request.URL;
    NSArray *activityItems = @[textToShare, urlToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    UIActivityViewControllerCompletionWithItemsHandler block = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
    {
        NSLog(@"activityType :%@", activityType);
        if (completed)
        {
            [CCHelper showBlackHudWithImage:[UIImage imageNamed:@"icon_check"] withText:NSLocalizedString(@"Share Article Successfully", nil)];
            NSLog(@"completed");
        }
        else
        {
            NSLog(@"cancel");
        }
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    };
    
    activityVC.completionWithItemsHandler = block;
    
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
    
}

- (void)loadContent{
    
    [self.refreshIconView beginRefreshing];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self.webView loadRequest:request];
    
}

@end
