//
//  ActivityTableViewCell.m
//  DonorSee
//
//  Created by star on 3/16/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "ActivityTableViewCell.h"
#import "MediaFile.h"


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
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
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
        CGRect labelFrame = lbFollowMessage.frame;
        labelFrame.size = [ActivityTableViewCell getActivityTextSize:lbFollowMessage.text];
        lbFollowMessage.frame = labelFrame;
        
        
        viPhotoContainer.frame = CGRectMake(viPhotoContainer.frame.origin.x,
                                            lbFollowMessage.frame.origin.y + lbFollowMessage.frame.size.height + 10.0,
                                            viPhotoContainer.frame.size.width,
                                            viPhotoContainer.frame.size.height);
        
        viPhotoContainer.hidden = NO;
        for(UIView* v in viPhotoContainer.subviews)
        {
            [v removeFromSuperview];
        }
        
        NSMutableArray *mediaArray = event.getMedia;
        
        if(mediaArray != nil)
        {
            float fx = 0;
            float fy = 0;
            float fw = viPhotoContainer.frame.size.width;
            float fOffset = 10.0;
            
            int playButtonDimen = 50;
            int index = 0;
            for(MediaFile* media in mediaArray)
            {
                NSString* thumbnailURL = media.getThumbnailURL;
                UIImageView* ivCell = [[UIImageView alloc] initWithFrame: CGRectMake(fx, fy, fw, fw)];
                ivCell.backgroundColor = [UIColor lightGrayColor];
                ivCell.layer.masksToBounds = YES;
                ivCell.layer.cornerRadius = 10.0;
                ivCell.contentMode = UIViewContentModeScaleAspectFill;
                [ivCell sd_setImageWithURL: [NSURL URLWithString: thumbnailURL]];
                [viPhotoContainer addSubview: ivCell];
                
                if(media.mediaType == VIDEO){//
                    int playButtonY = fy + (fw/2 - playButtonDimen/2);
                    int playButtonX = fx + (fw/2 - playButtonDimen/2);
                    UIImageView* ivPlayVideo = [[UIImageView alloc] initWithFrame: CGRectMake(playButtonX, playButtonY, playButtonDimen, playButtonDimen)];
                    ivPlayVideo.layer.masksToBounds = YES;
                    UIImage *img = [UIImage imageNamed:@"icon_play"];
                    [ivPlayVideo setImage:img];
                    [viPhotoContainer addSubview: ivPlayVideo];
                
                    ivPlayVideo.userInteractionEnabled = YES;
                
                    UITapGestureRecognizer *gestureVideoPlay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapVideo:)];
                    gestureVideoPlay.delegate = self;
                    ivPlayVideo.tag = index;
                    [ivPlayVideo addGestureRecognizer:gestureVideoPlay];
                }
                
                fy += fw + fOffset;
                index ++;
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


- (void) onTapVideo :(UITapGestureRecognizer *)gr
{
    UIImageView *theTappedImageView = (UIImageView *)gr.view;
    MediaFile* media = currentEvent.getMedia[theTappedImageView.tag];
    NSString* videoURL = media.mediaURL;
    [self.delegate openPlayer:videoURL];
}

- (void) onTapUser
{
    if ([self.delegate respondsToSelector:@selector(selectUser:)])
    {
        [self.delegate selectUser: currentEvent.creator];
    }
}

+ (CGFloat) getTextWidth{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.width;
    // HARDCODE calculate size by autoresize mask
    const CGFloat textLeftMargin = 61;
    const CGFloat textRightMargin = 34;
    CGFloat textWidth = screenHeight - textLeftMargin - textRightMargin;
    return textWidth;
}

+ (CGFloat) getImageWidth{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.width;
    // HARDCODE calculate size by autoresize mask
    const CGFloat imageLeftMargin = 61;
    const CGFloat imageRightMargin = 34;
    CGFloat imageWidth = screenHeight - imageLeftMargin - imageRightMargin;
    return imageWidth;
}

+ (CGSize) getActivityTextSize: (NSString *) text{
    CGFloat textWidth = [self getTextWidth];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString: text
                                                                         attributes:@{NSFontAttributeName: [UIFont fontWithName: FONT_THIN size: 14.0], NSParagraphStyleAttributeName: paragraphStyle}];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(textWidth, 50000)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size;
}

+ (CGFloat) getEventHeight: (Event*) a
{
    if ([a.type isEqualToString:@"update"] || [a.type isEqualToString:@"comment"]) {
        
        CGFloat imageWidth = [self getImageWidth];
        
        float fy = 51;
        float fOffset = 10.0;
        
        if (a.message != nil) {
            CGSize textSize = [self getActivityTextSize:a.message];
            
            fy += textSize.height;
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


@end
