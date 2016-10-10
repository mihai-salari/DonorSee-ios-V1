//
//  ActivityTableViewCell.h
//  DonorSee
//
//  Created by star on 3/16/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSTTweetLabel.h"
#import "Event.h"

@protocol ActivityTableViewCellDelegate <NSObject>
@optional
- (void) selectUser: (User*) user;
- (void) openPlayer: (NSString*) videoURL;
@end

@interface ActivityTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>
{
    Activity            *currentActivity;
    Event               *currentEvent;
}

@property (nonatomic, weak) IBOutlet UIImageView            *ivAvatar;
@property (nonatomic, weak) IBOutlet CustomSTTweetLabel     *lbMessage;
@property (nonatomic, weak) IBOutlet UILabel                *lbTime;
@property (nonatomic, weak) IBOutlet UILabel                *lbFollowMessage;
@property (nonatomic, weak) IBOutlet UIView                 *viPhotoContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayVideo;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint     *constraitMessageLeft;
@property (nonatomic, retain) id                            delegate;

@property (nonatomic, weak) NSString *postUsername;
@property (strong, nonatomic) UIImage *postUserAvatar;

- (void) setEvent:(Event *)event;
- (void)setPostusername: (NSString*) postusername setPostUserAvatar :(UIImage*) postUserAvatar;

+ (CGFloat) getEventHeight: (Event*) a;
@end
