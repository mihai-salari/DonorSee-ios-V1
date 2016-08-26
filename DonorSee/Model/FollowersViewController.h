//
//  FollowersViewController.h
//  DonorSee
//
//  Created by Keval on 25/08/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "FeedViewController.h"

@interface FollowersViewController : FeedViewController

@property (nonatomic, retain) User          *selectedUser;

@property (nonatomic, strong) NSString *viewType;

@end