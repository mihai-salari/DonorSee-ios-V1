//
//  WebDonateViewController.h
//  DonorSee
//
//  Created by star on 3/28/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface WebDonateViewController : BaseViewController
{
    
}

@property (nonatomic, assign) int       amount;
@property (nonatomic, strong) Feed      *selectedFeed;
@property (nonatomic, strong) id        prevViewController;
@end
