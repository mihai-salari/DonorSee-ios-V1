//
//  UITabBarItem+CustomBadge.h
//  DonorSee
//
//  Created by Keval on 09/07/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarItem (CustomBadge)

-(void) setMyAppCustomBadgeValue: (NSString *) value;
-(void) setCustomBadgeValue: (NSString *) value withFont: (UIFont *) font andFontColor: (UIColor *) color andBackgroundColor: (UIColor *) backColor;


@end
