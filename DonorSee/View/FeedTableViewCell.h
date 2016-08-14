//
//  FeedTableViewCell.h
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedTableViewCellDelegate <NSObject>
@optional
- (void) shareFeed: (Feed*) f image: (UIImage*) imgShare;
- (void) donateFeed: (Feed*) f;
- (void) selectFeed: (Feed*) f;
- (void) selectUser: (User*) user;
- (void) followUser: (User*) user;
- (void) unfollowUser: (User*) user;
@end

@interface FeedTableViewCell : UITableViewCell
{
    Feed*       currentFeed;
}

@property (nonatomic, retain) id   delegate;

- (void) setDonateFeed: (Feed*) f isDetail: (BOOL) isDetail;
+ (CGFloat) getHeight;

@end
