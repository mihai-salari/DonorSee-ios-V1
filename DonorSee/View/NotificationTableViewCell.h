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

@protocol NotificationTableViewCellDelegate <NSObject>
@optional
- (void) selectUser: (User*) user;
- (void) selectedNotification: (Activity*) a cell: (id) cell;
- (void) selectedNotificationNew: (Notification*) a cell: (id) cell;
@end

@interface NotificationTableViewCell : UITableViewCell
{
    Activity                *currentActivity;
    Notification            *currentNotificaion;
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

+ (CGFloat) getHeight: (Activity*) a;
+ (CGFloat) getNotificationHeight: (Notification*) n;
@end
