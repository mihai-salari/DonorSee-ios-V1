//
//  StaffPicksGlobalStyleBar.h
//  DonorSee
//
//  Created by Bogdan on 10/15/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLKFlexibleHeightBar.h"

@protocol StaffPicksGlobalStyleBarDelegate
@optional
- (void) selectedType: (int) type;
@end


@interface StaffPicksGlobalStyleBar : BLKFlexibleHeightBar
{
    UILabel                 *lbStaffPick;
    UILabel                 *lbGlobal;
    
    int                     selectedIndex;
}

@property (nonatomic, retain) id            delegate;

@end
