//
//  UITabBarItem+CustomBadge.m
//  DonorSee
//
//  Created by Keval on 09/07/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "UITabBarItem+CustomBadge.h"

#define CUSTOM_BADGE_TAG 99
#define OFFSET 0.6f


@implementation UITabBarItem (CustomBadge)


-(void) setMyAppCustomBadgeValue: (NSString *) value
{
    
    UIFont *myAppFont = [UIFont systemFontOfSize:13.0];
    UIColor *myAppFontColor = [UIColor orangeColor];
    UIColor *myAppBackColor = [UIColor orangeColor];
    
    [self setCustomBadgeValue:value withFont:myAppFont andFontColor:myAppFontColor andBackgroundColor:myAppBackColor];
}



-(void) setCustomBadgeValue: (NSString *) value withFont: (UIFont *) font andFontColor: (UIColor *) color andBackgroundColor: (UIColor *) backColor
{
    UIView *v = (UIView *)[self performSelector:@selector(view)];
    
    [self setBadgeValue:value];
    
    
    
    for(UIView *sv in v.subviews)
    {
        
        NSString *str = NSStringFromClass([sv class]);
        
        if([str isEqualToString:@"_UIBadgeView"])
        {
            for(UIView *ssv in sv.subviews)
            {
                // REMOVE PREVIOUS IF EXIST
                if(ssv.tag == CUSTOM_BADGE_TAG) { [ssv removeFromSuperview]; }
            }
            
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sv.frame.size.width, sv.frame.size.height)];
            
            
            [l setFont:font];
            [l setText:value];
            [l setBackgroundColor:backColor];
            [l setTextColor:color];
            [l setTextAlignment:NSTextAlignmentCenter];
            
            l.layer.cornerRadius = l.frame.size.height/2;
            l.layer.masksToBounds = YES;
            
            // Fix for border
            sv.layer.borderWidth = 1;
            sv.layer.borderColor = [backColor CGColor];
            sv.layer.cornerRadius = sv.frame.size.height/2;
            sv.layer.masksToBounds = YES;
            
            
            [sv addSubview:l];
            
            sv.layer.transform = CATransform3DIdentity;
            sv.layer.transform = CATransform3DMakeTranslation(-17.0, 1.0, 1.0);
            
            
            l.tag = CUSTOM_BADGE_TAG;
        }
    }
}



@end
