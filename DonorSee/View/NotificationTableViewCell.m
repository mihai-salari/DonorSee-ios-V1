//
//  NotificationTableViewCell.m
//  DonorSee
//
//  Created by star on 3/24/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "Notification.h"

@implementation NotificationTableViewCell
@synthesize viReadState;
@synthesize ivAvatar;
@synthesize lbMessage;
@synthesize lbTime;
@synthesize viTime;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    
    lbMessage.preferredMaxLayoutWidth = CGRectGetWidth(lbMessage.frame);
}

- (void) initUI
{
    viReadState.layer.masksToBounds = YES;
    viReadState.layer.cornerRadius = viReadState.frame.size.width / 2.0;
    
    lbMessage.customSelectionColor = [UIColor colorWithRed: 94.0/255.0 green: 94.0/255.0 blue: 94.0/255.0 alpha: 1.0];
    lbMessage.fontText = [UIFont fontWithName: FONT_LIGHT size: 14.0];
    lbMessage.fontUsername = [UIFont fontWithName: FONT_MEDIUM size: 14.0];
    [lbMessage updateTextAttribute];

    ivAvatar.layer.masksToBounds = YES;
    ivAvatar.layer.cornerRadius = ivAvatar.frame.size.width / 2.0;
}

- (void) setNotificationNew: (Notification *) n
{
    currentNotificaion = n;
    [self initUI];
    
    lbTime.text = [AppEngine dateTimeStringFromTimestap: n.register_date];
    lbMessage.text = [NotificationTableViewCell getMessages:n];
    [lbMessage sizeThatFits:CGSizeMake(279, CGFLOAT_MAX)];
    viReadState.hidden = n.is_read;
    _actionBtn.tag = 12;
    
    NSString* avatar = n.user_avatar;
    [ivAvatar sd_setImageWithURL: [NSURL URLWithString: avatar] placeholderImage: [UIImage imageNamed: DEFAULT_USER_IMAGE]];
}

+ (NSString*) getMessages: (Notification*) n {
    
    NSArray *nameSplit = [n.message componentsSeparatedByString:@"'s "];
    
    NSString *username = nameSplit.firstObject;
    username = [username stringByReplacingOccurrencesOfString:@" " withString:@"@"];
    
    
    
    NSString* message = [NSString stringWithFormat:@"!%@ %@", username, nameSplit.lastObject];
    
    
//    if(n.type == ACTIVITY_DONATED)
//    {
//        message = [NSString stringWithFormat: @"!%@ gave to this project", username];
//    }
//    else if(n.type == ACTIVITY_FULL_DONATED)
//    {
//        message = [NSString stringWithFormat: @"!%@ project got totaly funded!", username];
//    }
//    else if(n.type == ACTIVITY_FOLLOW_MESSAGE)
//    {
//        message = [NSString stringWithFormat: @"!%@ posted a follow up message to your project.", username];
//    }
    
    return message;
}

- (void) setNotification: (Activity *) a
{
    currentActivity = a;
    [self initUI];
    
    _actionBtn.tag = 11;
    
    NSString* avatar = a.user_avatar;
    lbTime.text = [AppEngine dateTimeStringFromTimestap: a.register_date];
    
    [ivAvatar sd_setImageWithURL: [NSURL URLWithString: avatar] placeholderImage: [UIImage imageNamed: DEFAULT_USER_IMAGE]];
    viReadState.hidden = a.is_read;
    
    lbMessage.text = [NotificationTableViewCell getNotificationMessage: a];
    [lbMessage sizeThatFits:CGSizeMake(279, CGFLOAT_MAX)];
    
    viTime.frame = CGRectMake(viTime.frame.origin.x, lbMessage.frame.origin.y + lbMessage.frame.size.height + 1.0, viTime.frame.size.width, viTime.frame.size.height);
}

+ (NSString*) getNotificationMessage: (Activity*) a
{
    //Message.
    NSString* filterUsername = [a.user_name stringByReplacingOccurrencesOfString: @" " withString: @"@"];
    NSString* message;
    if(a.type == ACTIVITY_DONATED)
    {
        message = [NSString stringWithFormat: @"!%@ gave !$%d to this project", filterUsername, a.amount];
    }
    else if(a.type == ACTIVITY_FULL_DONATED)
    {
        message = [NSString stringWithFormat: @"!%@ project got totaly funded!", filterUsername];
    }
    else if(a.type == ACTIVITY_FOLLOW_MESSAGE)
    {
        message = [NSString stringWithFormat: @"!%@ posted a follow up message to your project.", filterUsername];
    }
    
    return message;
}

+ (CGFloat) getHeight: (Activity*) a
{
    float fw = 220.0;
    if(IS_IPHONE_5)
    {
        fw = 220.0;
    }
    else if(IS_IPHONE_6 || IS_IPHONE_6P)
    {
        fw = 275.0;
    }
    
    float fy = 18.0;
    NSString* message = [NotificationTableViewCell getNotificationMessage: a];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString: message
                                                                         attributes:@{NSFontAttributeName: [UIFont fontWithName: FONT_LIGHT size: 14.0]}];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(fw, 50000)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    fy += size.height + 30.0;
    
    return fy;
}

+ (CGFloat) getNotificationHeight: (Notification*) n
{
    float fw = 220.0;
    if(IS_IPHONE_5)
    {
        fw = 220.0;
    }
    else if(IS_IPHONE_6 || IS_IPHONE_6P)
    {
        fw = 275.0;
    }
    
    float fy = 18.0;
    NSString* message = n.message;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString: message
                                                                         attributes:@{NSFontAttributeName: [UIFont fontWithName: FONT_LIGHT size: 14.0]}];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(fw, 50000)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    fy += size.height + 30.0;
    
    return fy;
}

- (IBAction) actionCell:(id)sender
{
    int tag = [(UIButton *)sender tag];
    
    if (tag == 11) {
        if ([self.delegate respondsToSelector:@selector(selectedNotification:cell:)])
        {
            [self.delegate selectedNotification: currentActivity cell: self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(selectedNotificationNew:cell:)])
        {
            [self.delegate selectedNotificationNew: currentNotificaion cell: self];
        }
    }
    

}

@end
