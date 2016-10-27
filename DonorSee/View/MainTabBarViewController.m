//
//  MainTabBarViewController.m
//  DonorSee
//
//  Created by star on 3/1/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "UploadViewController.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "NotificationViewController.h"

@interface MainTabBarViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong) NSMutableArray *notificationIds;

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    [AppDelegate getDelegate].mainTabBar = self;
    
    _notificationIds = [NSMutableArray array];
    
    UITabBar *tabBar = self.tabBar;
    
    UITabBarItem *tabBarItem0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:3];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:4];
    
    [tabBarItem0 setImageInsets:  UIEdgeInsetsMake(5, 0, -5, 0)];
    [tabBarItem0 setImage: [[UIImage imageNamed: @"tab_donate_normal.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem0 setSelectedImage: [[UIImage imageNamed: @"tab_donate_sel.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];

    
    [tabBarItem1 setImageInsets:  UIEdgeInsetsMake(5, 0, -5, 0)];
    [tabBarItem1 setImage: [[UIImage imageNamed: @"tab_explore_normal.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem1 setSelectedImage: [[UIImage imageNamed: @"tab_explore_sel.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    
    [tabBarItem2 setImageInsets:  UIEdgeInsetsMake(5, 0, -5, 0)];
    [tabBarItem2 setImage: [[UIImage imageNamed: @"tab_upload_normal.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem2 setSelectedImage: [[UIImage imageNamed: @"tab_upload_sel.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    
    [tabBarItem3 setImageInsets:  UIEdgeInsetsMake(5, 0, -5, 0)];
    [tabBarItem3 setImage: [[UIImage imageNamed: @"tab_profile_normal.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem3 setSelectedImage: [[UIImage imageNamed: @"tab_profile_sel.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];

    [tabBarItem4 setImageInsets:  UIEdgeInsetsMake(5, 0, -5, 0)];
    [tabBarItem4 setImage: [[UIImage imageNamed: @"tab_notification_normal.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem4 setSelectedImage: [[UIImage imageNamed: @"tab_notification_sel.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];

    [[UITabBar appearance] setBackgroundImage: [UIImage imageNamed: @"bottom_tab_bar_bg.png"]];
//    [[UITabBar appearance] setShadowImage: [UIImage imageNamed: @"bottom_tab_bar_separator.png"]];
    
    self.tabBar.frame = CGRectMake(0, self.view.frame.size.height - TAB_BAR_HEIGHT, self.view.frame.size.width, TAB_BAR_HEIGHT);
    [[UITabBar appearance] setBackgroundColor:[UIColor colorWithRed: 56.0/255.0f green: 56.0f/255.0f blue: 58.0f/255.0f alpha: 1.0f]];
    
   self.selectedIndex = 1;
}

- (UITabBarItem *)getNotificationTabItem {
    return [self.tabBar.items objectAtIndex:4];
}

//====================================================================================================
-(void)viewWillLayoutSubviews
{
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = TAB_BAR_HEIGHT;
    tabFrame.origin.y = self.view.frame.size.height - TAB_BAR_HEIGHT;
    self.tabBar.frame = tabFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) updateNotificationBadge
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateNotificationBadge) object:nil];
    [self performSelector:@selector(updateNotificationBadge) withObject:nil afterDelay:10];
    
    if([AppEngine sharedInstance].currentUser == nil) {
        [self setNotificationsCount:0];
        return;
    }
    
    [[NetworkClient sharedClient] getUnReadCountInfo:[AppEngine sharedInstance].currentUser.user_id success:^(NSDictionary *dicUser) {
        if ([dicUser objectForKey:@"count"]) {
            int totalCount = [[dicUser objectForKey:@"count"] intValue];
            [self setNotificationsCount:totalCount];
        }

    } failure:^(NSString *errorMessage) {
        
    }];
}

- (void) setNotificationsCount:(int)totalCount{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if (totalCount > 0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalCount];
        [[self getNotificationTabItem] setMyAppCustomBadgeValue:@"0"];
    } else {
        [[self getNotificationTabItem] setMyAppCustomBadgeValue:nil];
    }
}

- (void) cancelUpdateNotification {
    //NSLog(@"Cancelled Notification...");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateNotificationBadge) object:nil];
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController: (UIViewController *)viewController
{
    
        if ([viewController isKindOfClass:[ProfileViewController class]]) {
            ProfileViewController *profileController = (ProfileViewController *)viewController;
            [profileController showSignupPage];
        }
        
        if ([viewController isKindOfClass:[NotificationViewController class]]) {
            NotificationViewController *profileController = (NotificationViewController *)viewController;
            [profileController showSignupPage];
        }
}

@end
