//
//  ShareViewController.h
//  DonorSee
//
//  Created by star on 3/9/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface ShareViewController : BaseViewController
{
    
}

- (void) shareFeedInFacebook: (Feed*) f image: (UIImage*) imgShare;
- (void) shareFeedInTwitter: (Feed*) f image: (UIImage*) imgShare;
- (void) shareFeed:(Feed *)f image: (UIImage*) imgShare;


@end
