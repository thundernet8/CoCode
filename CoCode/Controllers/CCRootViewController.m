//
//  CCRootViewController.m
//  CoCode
//
//  Created by wuxueqian on 15/10/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCRootViewController.h"

#import "SCNavigationController.h"

#import "CCMenuView.h"

#import "CCNewestViewController.h"
#import "CCLatestViewController.h"
#import "CCHotViewController.h"
#import "CCCategoriesViewController.h"
#import "CCTagsViewController.h"
#import "CCProfileViewController.h"

#import "CCLoginViewController.h"

#import "UIView+REFrosted.h"
#import "UIImage+REFrosted.h"

@interface CCRootViewController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

//Current Controller Index
@property (nonatomic, assign) NSInteger currentControllerIndex;

//Gesture
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *panGestureRecognizer;

//Menu View
@property (nonatomic, strong) CCMenuView *menuView;

//Button for Showing Menu
@property (nonatomic, strong) UIButton *rootBackgroundButton;

//ViewControllers included in Menu
@property (nonatomic, strong) CCNewestViewController *newestViewController;
@property (nonatomic, strong) CCLatestViewController *latestViewController;
@property (nonatomic, strong) CCHotViewController *hotViewController;
@property (nonatomic, strong) CCCategoriesViewController *catViewController;
@property (nonatomic, strong) CCTagsViewController *tagViewController;
@property (nonatomic, strong) CCProfileViewController *profileViewController;

//Navigation Controller
@property (nonatomic, strong) SCNavigationController *newestNavigationController;
@property (nonatomic, strong) SCNavigationController *latestNavigationController;
@property (nonatomic, strong) SCNavigationController *hotNavigationController;
@property (nonatomic, strong) SCNavigationController *catNavigationController;
@property (nonatomic, strong) SCNavigationController *tagNavigationController;
@property (nonatomic, strong) SCNavigationController *profileNavigationController;

//ContainView
@property (nonatomic, strong) UIView *containerView;

//Blur Image
@property (nonatomic, strong) UIImageView *rootBackgroundBlurView;

@end

@implementation CCRootViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.currentControllerIndex = 0;
        [CCSettingManager sharedManager];
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    [self configureControllers];
    [self configureViews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureGestures];
    [self configureNotifications];
}

#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Delegate
    self.panGestureRecognizer.delegate = self;
    self.navigationController.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View Layout

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.containerView.frame = self.view.frame;
    self.rootBackgroundButton.frame = self.view.frame;
    self.rootBackgroundBlurView.frame = self.view.frame;
}

#pragma mark - Configure Views

- (void)configureViews{
    //Custom Button for Tapping to Show Menu
    self.rootBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rootBackgroundButton.backgroundColor = kBlackColor;
    self.rootBackgroundButton.alpha = 0.0;
    self.rootBackgroundButton.hidden = YES;
    [self.view addSubview:self.rootBackgroundButton];
    
    //Menu  View
    self.menuView = [[CCMenuView alloc] initWithFrame:CGRectMake(-kMenuWidth, 0, kMenuWidth, kScreenHeight)];
    [self.view addSubview:self.menuView];
    
    //Tap to Show Menu
    @weakify(self);
    //__weak typeof(CCRootViewController) *weakSelf = self;
    //bk_whenTapped is from BlocksKit
    [self.rootBackgroundButton bk_whenTapped:^{
        @strongify(self);
        [UIView animateWithDuration:0.25 animations:^{
            [self setMenuOffset:0.0];
        }];
    }];
    
    //Show Selected Controller View
    [self.menuView setDidSelectedIndexBlock:^(NSInteger index) {
        @strongify(self);
        [self showViewControllerAtIndex:index animated:YES];
        [CCSettingManager sharedManager].selectedSectionIndex = index;
        
    }];
}

- (void)configureControllers{
    //Add Container View
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:self.containerView];
    
    //Sections View Controller init
    self.newestViewController = [[CCNewestViewController alloc] init];
    self.newestNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.newestViewController];
    
    self.latestViewController = [[CCLatestViewController alloc] init];
    self.latestNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.latestViewController];
    
    self.hotViewController = [[CCHotViewController alloc] init];
    self.hotNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.hotViewController];
    
    //TODO 
    self.catViewController = [[CCCategoriesViewController alloc] init];
    self.catNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.catViewController];
    
    self.tagViewController = [[CCTagsViewController alloc] init];
    self.tagNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.tagViewController];
    
    self.profileViewController = [[CCProfileViewController alloc] init];
    self.profileNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.profileViewController];
    
    //Add Selected Controller
    [self.containerView addSubview:[self viewControllerForIndex:kSetting.selectedSectionIndex].view];
    self.currentControllerIndex = kSetting.selectedSectionIndex;
    
    //Background Blur
    self.rootBackgroundBlurView = [[UIImageView alloc] init];
    self.rootBackgroundBlurView.userInteractionEnabled = NO;
    self.rootBackgroundBlurView.alpha = 0.0;
    [self.containerView addSubview:self.rootBackgroundBlurView];
}

#pragma mark - Private Methods

//Menu View Offset
- (void)setMenuOffset:(CGFloat)offset{
    self.menuView.x = offset - kMenuWidth;
    [self.menuView setOffsetProgress:offset/kMenuWidth];

    self.rootBackgroundButton.alpha = offset/kMenuWidth*0.3;
    UIViewController *previousViewController = [self viewControllerForIndex:self.currentControllerIndex];
    previousViewController.view.x = offset/6.0;
}

//Show ViewController included in Menu
- (void)showViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated{
    if (self.currentControllerIndex != index) {
        @weakify(self);
        void (^showControllerBlock)() = ^{
            @strongify(self);
            UIViewController *previousViewController = [self viewControllerForIndex:self.currentControllerIndex];
            UIViewController *willShowViewController = [self viewControllerForIndex:index];
            if (willShowViewController) {
                BOOL isViewInRootView = NO;
                for (UIView *subView in self.containerView.subviews) {
                    if ([subView isEqual:willShowViewController.view]) {
                        isViewInRootView = YES;
                    }
                }
                if (isViewInRootView) {
                    willShowViewController.view.x = 320.0;
                    [self.containerView bringSubviewToFront:willShowViewController.view];
                }else{
                    [self.containerView addSubview:willShowViewController.view];
                    willShowViewController.view.x = 320.0;
                }
                if (animated) {
                    [UIView animateWithDuration:0.2 animations:^{
                        previousViewController.view.x += 20.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                    [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.2 options:UIViewAnimationOptionCurveLinear animations:^{
                        willShowViewController.view.x = 0.0;
                    } completion:nil];
                    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        [self setMenuOffset:0.0];
                    } completion:nil];
                }else{
                    previousViewController.view.x += 20.0;
                    willShowViewController.view.x = 0.0;
                    [self setMenuOffset:0.0];
                }
                self.currentControllerIndex = index;
            }
        };
        
        showControllerBlock();
        
    }else{
        UIViewController *willShowViewController = [self viewControllerForIndex:index];
        [UIView animateWithDuration:0.4 animations:^{
            willShowViewController.view.x = 0.0;
        } completion:nil];
        [UIView animateWithDuration:0.5 animations:^{
            [self setMenuOffset:0.0];
        }];
    }
}

//Recognize ViewController in Menu
- (UIViewController *)viewControllerForIndex:(NSInteger)index{
    UIViewController *viewController;
    switch (index) {
        case 0:
            viewController = self.newestNavigationController;
            break;
        case 1:
            viewController = self.latestNavigationController;
            break;
        case 2:
            viewController = self.hotNavigationController;
            break;
        case 3:
            viewController = self.catNavigationController;
            break;
        case 4:
            viewController = self.tagNavigationController;
            break;
        case 5:
            viewController = self.profileNavigationController;
            break;
            
        default:
            break;
    }
    return viewController;
}

//ScreenShot for Blur
- (void)setBlurredScreenShot{
    __block UIImage *screenShot = [self.view re_screenshot];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIColor *blurColor = [UIColor colorWithWhite:0.97 alpha:0.5];
        if (kCurrentTheme == CCThemeNight) {
            blurColor = [UIColor colorWithWhite:0.03 alpha:0.5];
        }
        screenShot = [screenShot re_applyBlurWithRadius:12.0 tintColor:blurColor saturationDeltaFactor:1.0 maskImage:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.menuView.blurredImage = screenShot;
            self.rootBackgroundBlurView.image = screenShot;
        });
    });
}

#pragma mark - Gesture

- (void)configureGestures{
    //Left Slide Gesture
    self.panGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePanRecognizer:)];
    self.panGestureRecognizer.edges = UIRectEdgeLeft;
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    //All Gesture for Background Button
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanRecognizer:)];
    panRecognizer.delegate = self;
    [self.rootBackgroundButton addGestureRecognizer:panRecognizer];
}

- (void)handleEdgePanRecognizer:(UIScreenEdgePanGestureRecognizer *)recognizer{
    CGFloat progress = [recognizer translationInView:self.view].x / kMenuWidth;
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.rootBackgroundButton.hidden = NO;
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self setMenuOffset:kMenuWidth*progress];
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
        CGFloat velocity = [recognizer velocityInView:self.view].x;
        if (velocity > 20 || progress > 0.5) {
            [UIView animateWithDuration:(1-progress)/1.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:3.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self setMenuOffset:kMenuWidth];
            } completion:^(BOOL finished) {
                
            }];
        }else{
            [UIView animateWithDuration:progress/3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self setMenuOffset:0];
            } completion:^(BOOL finished) {
                self.rootBackgroundButton.hidden = YES;
                self.rootBackgroundButton.alpha = 0.0;
            }];
        }
    }
}

- (void)handlePanRecognizer:(UIPanGestureRecognizer *)recognizer{
    CGFloat progress = [recognizer translationInView:self.rootBackgroundButton].x / (self.rootBackgroundButton.width * 0.5);
    progress = -MIN(progress, 0.0);
    
    [self setMenuOffset:kMenuWidth - kMenuWidth*progress];
    
    static CGFloat sumProgress = 0;
    static CGFloat lastProgress = 0;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        sumProgress = lastProgress = 0;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        sumProgress += progress > lastProgress ? progress : progress * (-1);
        lastProgress = progress;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.3 animations:^{
            if (sumProgress > 0.1) {
                [self setMenuOffset:0];
            }else{
                [self setMenuOffset:kMenuWidth];
            }
        } completion:^(BOOL finished) {
            self.rootBackgroundButton.hidden = sumProgress > 0.1 ? YES:NO;
        }];
    }
}

//Gesture Delegate Method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
            return YES;
        }
        if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Notification

- (void)configureNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveShowMenuNotification) name:kShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveResetInactiveDelegateNotification) name:kRootViewControllerResetDelegateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCancelInactiveDelegateNotification) name:kRootViewControllerCancelDelegateNotification object:nil];
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kShowLoginVCNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        CCLoginViewController *loginViewController = [[CCLoginViewController alloc] init];
        [self presentViewController:loginViewController animated:YES completion:^{
            
        }];
    }];
}

- (void)didReceiveShowMenuNotification{
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:3.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setMenuOffset:kMenuWidth];
        self.rootBackgroundButton.hidden = NO;
    } completion:nil];
}

- (void)didReceiveResetInactiveDelegateNotification{
    self.panGestureRecognizer.enabled = YES;
}

- (void)didReceiveCancelInactiveDelegateNotification{
    self.panGestureRecognizer.enabled = NO;
}

@end
