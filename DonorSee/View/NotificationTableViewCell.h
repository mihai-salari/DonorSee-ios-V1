//
//  NotificationTableViewCell.h
//  DonorSee
//
//  Created by star on 3/24/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSTTweetLabel.h"
#import "Notification.h"
#import "Event.h"

@protocol NotificationTableViewCellDelegate <NSObject>
@optional
- (void) selectUser: (User*) user;
- (void) selectedNotification: (Event*) a cell: (id) cell;
- (void) selectedNotificationNew: (Notification*) a cell: (id) cell;
@end

@interface NotificationTableViewCell : UITableViewCell
{
    Activity                *currentActivity;
    Notification            *currentNotificaion;
    Event                   *currentEvent;
}

@property (nonatomic, weak) IBOutlet UIImageView        *ivAvatar;
@property (nonatomic, weak) IBOutlet CustomSTTweetLabel *lbMessage;
@property (nonatomic, weak) IBOutlet UIView             *viTime;
@property (nonatomic, weak) IBOutlet UILabel            *lbTime;
@property (nonatomic, weak) IBOutlet UIView             *viReadState;
@property (nonatomic, retain)  id                      delegate;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

- (void) setNotification: (Activity*) a;
- (void) setNotificationNew: (Notification *) n;
- (void) setEventNotification:(Event *)event;
+ (CGFloat) getHeight: (Event*) a;
+ (CGFloat) getNotificationHeight: (Notification*) n;
@end
