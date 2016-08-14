//
//  DetailFeedViewController.h
//  DonorSee
//
//  Created by star on 3/9/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "ShareViewController.h"

@interface DetailFeedViewController : ShareViewController
{
    
}

@property (nonatomic, retain) Feed              *selectedFeed;
@property (nonatomic, assign) BOOL              isFollowMessage;

- (void) loadActivities;

@end
