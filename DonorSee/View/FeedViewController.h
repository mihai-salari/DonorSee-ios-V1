//
//  FeedViewController.h
//  DonorSee
//
//  Created by star on 3/11/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "ShareViewController.h"

@interface FeedViewController : ShareViewController
{
    NSMutableArray              *arrItemFeeds;
}

@property (strong, nonatomic) IBOutlet UITableView              *tbMain;

- (void) refreshAllCells;
- (void) followUser: (User*) user;
- (void) unfollowUser: (User*) user;
- (void) finishedFollowForFeed: (NSNotification*) notification;

- (void) getProfileLinkForUserid:(int)userid;
- (void) shareUserInEmail:(int)userid;
- (void) shareUserInTwitter:(int)userid;
- (void) shareUserInFacebook:(int)userid;

- (void) selectUser: (User*) user;
@end
