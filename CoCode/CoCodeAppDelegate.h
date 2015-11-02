//
//  AppDelegate.h
//  CoCode
//
//  Created by wuxueqian on 15/10/30.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "SCNavigationController.h"

@class CCRootViewController;

@interface CoCodeAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, assign) SCNavigationController *currentNavigationController;
@property (nonatomic, strong) CCRootViewController *rootViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

