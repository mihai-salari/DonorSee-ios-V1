//
//  ActivityTableViewCell.m
//  DonorSee
//
//  Created by star on 3/16/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "ActivityTableViewCell.h"


@implementation ActivityTableViewCell
@synthesize ivAvatar;
@synthesize lbMessage;
@synthesize lbTime;
@synthesize lbFollowMessage;
@synthesize viPhotoContainer;
@synthesize constraitMessageLeft;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initUI
{
    ivAvatar.userInteractionEnabled = YES;
    ivAvatar.layer.masksToBounds = YES;
    ivAvatar.layer.cornerRadius = ivAvatar.frame.size.width/2.0;
    ivAvatar.contentMode = UIViewContentModeScaleAspectFill;
    
    UITapGestureRecognizer* gestureAvatar = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapUser)];
    gestureAvatar.numberOfTapsRequired = 1;
    [ivAvatar addGestureRecognizer: gestureAvatar];
    
    lbMessage.customSelectionColor = [UIColor colorWithRed: 94.0/255.0 green: 94.0/255.0 blue: 94.0/255.0 alpha: 1.0];
    lbMessage.fontText = [UIFont fontWithName: FONT_LIGHT size: 14.0];
    lbMessage.fontUsername = [UIFont fontWithName: FONT_MEDIUM size: 14.0];
    [lbMessage updateTextAttribute];
}

#pragma mark -
#pragma mark - setPostusername [ METHOD ]

- (void)setPostusername: (NSString*) postusername setPostUserAvatar :(UIImage*) postUserAvatar{
    
    _postUsername = postusername;
    NSLog(@"%@",_postUsername);
    
    
    _postUserAvatar = postUserAvatar;
    
}

- (void) setEvent:(Event *)event {
    currentEvent = event;
    [self initUI];
    
    NSLog(@"activity.user_avatar _%@_", event.creator.avatar);
    
    NSString* avatar = event.creator.avatar;
    lbTime.text = [AppEngine dataTimeStringFromDate:event.created_at];
    [ivAvatar sd_setImageWithURL: [NSURL URLWithString: avatar] placeholderImage: [UIImage imageNamed: DEFAULT_USER_IMAGE]];
    
    lbFollowMessage.text = @"";
    NSString* message = @"";
    if ([event.type isEqualToString:@"update"] || [event.type isEqualToString:@"comment"]) {
        NSString* filterUsername = [event.creator.name stringByReplacingOccurrencesOfString: @" " withString: @"@"];
        message = [NSString stringWithFormat: @"!%@ posted a follow up", filterUsername];
        
        if ([event.type isEqualToString:@"comment"]) {
            message = [NSString stringWithFormat: @"!%@ posted a comment", filterUsername];    
        }
        
        //Follow Message.
        lbFollowMessage.hidden = NO;
        lbFollowMessage.text = event.message;
        //[lbFollowMessage sizeThatFits:CGSizeMake(245, CGFLOAT_MAX)];
        [lbFollowMessage sizeToFit];
        
        CGRect frm = lbFollowMessage.frame;
        frm.size.width = 245;
        lbFollowMessage.frame = frm;
        
        viPhotoContainer.frame = CGRectMake(viPhotoContainer.frame.origin.x,
                                            lbFollowMessage.frame.origin.y + lbFollowMessage.frame.size.height + 10.0,
                                            viPhotoContainer.frame.size.width,
                                            viPhotoContainer.frame.size.height);
        
        viPhotoContainer.hidden = NO;
        for(UIView* v in viPhotoContainer.subviews)
        {
            [v removeFromSuperview];
        }
        
        if(event.photo_urls != nil && event.photo_urls.length > 0)
        {
            float fx = 0;
            float fy = 0;
            float fw = viPhotoContainer.frame.size.width;
            float fOffset = 10.0;
            
            NSArray *photos = [event.photo_urls componentsSeparatedByString:@","];
            
            
            for(NSString* photoKey in photos)
            {
                UIImageView* ivCell = [[UIImageView alloc] initWithFrame: CGRectMake(fx, fy, fw, fw)];
                ivCell.backgroundColor = [UIColor lightGrayColor];
                ivCell.layer.masksToBounds = YES;
                ivCell.layer.cornerRadius = 10.0;
                ivCell.contentMode = UIViewContentModeScaleAspectFill;
                [ivCell sd_setImageWithURL: [NSURL URLWithString: photoKey]];
                [viPhotoContainer addSubview: ivCell];
                
                fy += fw + fOffset;
            }
            
            viPhotoContainer.frame = CGRectMake(viPhotoContainer.frame.origin.x, viPhotoContainer.frame.origin.y, viPhotoContainer.frame.size.width, fy);
        
        }
    }
    
    if ([event.type isEqualToString:@"create"]) {
        NSString* filterUsername = [event.creator.name stringByReplacingOccurrencesOfString: @" " withString: @"@"];
        message = [NSString stringWithFormat: @"!%@ created this project", filterUsername];
        lbFollowMessage.hidden = YES;
        viPhotoContainer.hidden = YES;
    }
    
    if ([event.type isEqualToString:@"give"]) {
        NSString* filterUsername = [event.creator.name stringByReplacingOccurrencesOfString: @" " withString: @"@"];
        message = [NSString stringWithFormat: @"!%@ gave to this project", filterUsername];
        lbFollowMessage.hidden = YES;
        viPhotoContainer.hidden = YES;
    }
    
    if ([event.type isEqualToString:@"fund"]) {
        NSString* filterUsername = [event.recipient.name stringByReplacingOccurrencesOfString: @" " withString: @"@"];
        message = [NSString stringWithFormat: @"!%@'s project was totally funded!", filterUsername];
        
        [ivAvatar sd_setImageWithURL: [NSURL URLWithString: event.recipient.avatar] placeholderImage: [UIImage imageNamed: DEFAULT_USER_IMAGE]];
        lbFollowMessage.hidden = YES;
        viPhotoContainer.hidden = YES;
    }
    
    
    lbMessage.text = message;
    [self layoutIfNeeded];
}

- (void) setActivity: (Activity*) activity
{
    currentActivity = activity;
    [self initUI];
    
    NSLog(@"activity.user_avatar _%@_", activity.user_avatar);
    
    NSString* avatar = activity.user_avatar;
    lbTime.text = [AppEngine dateTimeStringFromTimestap: activity.register_date];
    [ivAvatar sd_setImageWithURL: [NSURL URLWithString: avatar] placeholderImage: [UIImage imageNamed: DEFAULT_USER_IMAGE]];
    
    //Message.
    NSString* filterUsername = [activity.user_name stringByReplacingOccurrencesOfString: @" " withString: @"@"];
    
    NSString *Postusername = [_postUsername stringByReplacingOccurrencesOfString: @" " withString: @"@"];
    NSLog(@"inside%@",Postusername);
    
    NSString* message;
    if(activity.type == ACTIVITY_DONATED)
    {
        message = [NSString stringWithFormat: @"!%@ gave to this project", filterUsername];
        
        lbFollowMessage.hidden = YES;
        viPhotoContainer.hidden = YES;
    }
    else if(activity.type == ACTIVITY_FULL_DONATED)
    {
        message = [NSString stringWithFormat: @"!%@'s project was totally funded!", Postusername];
        if (_postUserAvatar != nil) {
            [ivAvatar setImage:_postUserAvatar];
        }
        
        
        lbFollowMessage.hidden = YES;
        viPhotoContainer.hidden = YES;
    }
    else if(activity.type == ACTIVITY_FOLLOW_MESSAGE)
    {
        message = [NSString stringWithFormat: @"!%@ posted a follow up", filterUsername];
     
        //Follow Message.
        lbFollowMessage.hidden = NO;
        lbFollowMessage.text = activity.followMessage.message;
        //[lbFollowMessage sizeThatFits:CGSizeMake(245, CGFLOAT_MAX)];
        [lbFollowMessage sizeToFit];
        
        CGRect frm = lbFollowMessage.frame;
        frm.size.width = 245;
        lbFollowMessage.frame = frm;
        
        viPhotoContainer.frame = CGRectMake(viPhotoContainer.frame.origin.x,
                                            lbFollowMessage.frame.origin.y + lbFollowMessage.frame.size.height + 10.0,
                                            viPhotoContainer.frame.size.width,
                                            viPhotoContainer.frame.size.height);
        
        viPhotoContainer.hidden = NO;
        for(UIView* v in viPhotoContainer.subviews)
        {
            [v removeFromSuperview];
        }
        
        if(activity.followMessage.arrPhotos != nil && [activity.followMessage.arrPhotos count] > 0)
        {
            float fx = 0;
            float fy = 0;
            float fw = viPhotoContainer.frame.size.width;
            float fOffset = 10.0;
            
            for(NSString* photoKey in activity.followMessage.arrPhotos)
            {
                UIImageView* ivCell = [[UIImageView alloc] initWithFrame: CGRectMake(fx, fy, fw, fw)];
                ivCell.backgroundColor = [UIColor lightGrayColor];
                ivCell.layer.masksToBounds = YES;
                ivCell.layer.cornerRadius = 10.0;
                ivCell.contentMode = UIViewContentModeScaleAspectFill;
                //[ivCell sd_setImageWithURL: [NSURL URLWithString: [[JAmazonS3ClientManager defaultManager] getPathForPhoto: photoKey]]];
                [viPhotoContainer addSubview: ivCell];

                fy += fw + fOffset;
            }
            
            viPhotoContainer.frame = CGRectMake(viPhotoContainer.frame.origin.x, viPhotoContainer.frame.origin.y, viPhotoContainer.frame.size.width, fy);
        }
    }
    lbMessage.text = message;
    [self layoutIfNeeded];
}

- (void) onTapUser
{
    if ([self.delegate respondsToSelector:@selector(selectUser:)])
    {
        [self.delegate selectUser: currentEvent.creator];
    }
}

+ (CGFloat) getEventHeight: (Event*) a
{
    if ([a.type isEqualToString:@"update"] || [a.type isEqualToString:@"comment"]) {
        
        const CGFloat screenHeight = [UIScreen mainScreen].bounds.size.width;
        
        // HARDCODE calculate size by autoresize mask
        const CGFloat textLeftMargin = 66;
        const CGFloat textRightMargin = 9;
        const CGFloat textWidth = screenHeight - textLeftMargin - textRightMargin;
        
        // HARDCODE calculate size by autoresize mask
        const CGFloat imageLeftMargin = 61;
        const CGFloat imageRightMargin = 34;
        const CGFloat imageWidth = screenHeight - imageLeftMargin - imageRightMargin;
        
        
        float fy = 51;
        float fOffset = 10.0;
        
        if (a.message != nil) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString: a.message
                                                                                 attributes:@{NSFontAttributeName: [UIFont fontWithName: FONT_LIGHT size: 14.0], NSParagraphStyleAttributeName: paragraphStyle}];
            CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(textWidth, 50000)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            CGSize size = rect.size;
            
            fy += size.height;
        }
        
        if(a.photo_urls.length > 0)
        {
            NSArray *photos = [a.photo_urls componentsSeparatedByString:@","];
            fy += [photos count] * (imageWidth + fOffset) ;
        }
        
        
        fy += fOffset;
        
        
        return fy;
    }
    return 75;
}

+ (CGFloat) getHeight: (Activity*) a
{
    if(a.type == ACTIVITY_DONATED || a.type == ACTIVITY_FULL_DONATED)
    {
        return 55.0;
    }
    else if(a.type == ACTIVITY_FOLLOW_MESSAGE)
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
        
        float fy = 51;
        float fOffset = 10.0;
        
        if (a.followMessage != nil) {
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString: a.followMessage.message
                                                                                 attributes:@{NSFontAttributeName: [UIFont fontWithName: FONT_LIGHT size: 14.0]}];
            CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(fw, 50000)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            CGSize size = rect.size;
            if([a.followMessage.arrPhotos count] > 0)
            {
                fy += size.height + [a.followMessage.arrPhotos count] * (fw + fOffset) + 20;
            }
            else
            {
                fy += size.height + 5.0;
            }
        }
        
        return fy;
    }
    
    return 100.0;
}

@end
