//
//  MainTabBarViewController.h
//  DonorSee
//
//  Created by star on 3/1/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITabBarItem+CustomBadge.h"

@interface MainTabBarViewController : UITabBarController

- (UITabBarItem *)getNotificationTabItem;
- (void) updateNotificationBadge;
@end
