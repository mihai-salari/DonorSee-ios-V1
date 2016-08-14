//
//  AppDelegate.h
//  DonorSee
//
//  Created by star on 2/28/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow*                 window;
@property (strong, nonatomic) UINavigationController*   navigator;
@property (strong, nonatomic) MainTabBarViewController* mainTabBar;
+ (AppDelegate*) getDelegate;

- (void) gotoOtherProfile: (NSDictionary*) params;
@end

