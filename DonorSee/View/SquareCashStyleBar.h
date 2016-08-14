//
//  SquareCashStyleBar.h
//  BLKFlexibleHeightBar Demo
//
//  Created by Bryan Keller on 2/19/15.
//  Copyright (c) 2015 Bryan Keller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLKFlexibleHeightBar.h"

@protocol SquareCashStyleBarDelegate
@optional
- (void) selectedType: (int) type;
@end


@interface SquareCashStyleBar : BLKFlexibleHeightBar
{
    UILabel                 *lbGlobal;
    UILabel                 *lbPersonal;
    
    int                     selectedIndex;
}

@property (nonatomic, retain) id            delegate;

@end
