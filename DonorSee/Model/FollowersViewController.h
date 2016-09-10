//
//  FollowersViewController.h
//  DonorSee
//
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "FeedViewController.h"

@interface FollowersViewController : FeedViewController

@property (nonatomic, assign)NSInteger intSelectedTab;
@property (nonatomic, retain) User          *selectedUser;
@property (weak, nonatomic) IBOutlet UIView *ActiveSendGift;
@property (weak, nonatomic) IBOutlet UIView *ActiveResevedGifts;
@property (weak, nonatomic) IBOutlet UIButton *btnReceiveGift;

@property (weak, nonatomic) IBOutlet UIButton *btnSendGift;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableFromTop;
@property (nonatomic, strong) NSString *viewType;


@end
