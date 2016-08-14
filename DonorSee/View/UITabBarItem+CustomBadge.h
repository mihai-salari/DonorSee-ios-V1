//
//  UITabBarItem+CustomBadge.h
//  DonorSee
//
//  Copyright © 2016 DonorSee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarItem (CustomBadge)

-(void) setMyAppCustomBadgeValue: (NSString *) value;
-(void) setCustomBadgeValue: (NSString *) value withFont: (UIFont *) font andFontColor: (UIColor *) color andBackgroundColor: (UIColor *) backColor;


@end
