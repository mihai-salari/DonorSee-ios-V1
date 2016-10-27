//
//  FeedTableViewCell.m
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "FeedTableViewCell.h"
#import "PlayerViewController.h"
#import "CountryUtils.h"

//#import "JAmazonS3ClientManager.h"
@import CircleProgressView;

@interface FeedTableViewCell()
{
    
}
@property (weak, nonatomic) IBOutlet UIImageView        *ivUserAvatar;
@property (weak, nonatomic) IBOutlet UILabel            *lbUsername;
@property (weak, nonatomic) IBOutlet UILabel            *lbPostTime;
@property (weak, nonatomic) IBOutlet UIView             *viGive;
@property (weak, nonatomic) IBOutlet UIButton           *btGive;
@property (weak, nonatomic) IBOutlet UILabel            *lbGiveTitle;
@property (weak, nonatomic) IBOutlet UILabel            *lbMaxPrice;
@property (weak, nonatomic) IBOutlet UILabel            *lbDescription;
@property (weak, nonatomic) IBOutlet UIImageView        *ivFeed;
@property (weak, nonatomic) IBOutlet CircleProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton           *btHeart;
@property (weak, nonatomic) IBOutlet UIImageView        *ivGave;
@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *ivPlayVideo;
@property (weak, nonatomic) IBOutlet UIImageView *ivCountry;
@property (weak, nonatomic) IBOutlet UILabel *lbCountry;

@end

@implementation FeedTableViewCell
@synthesize ivUserAvatar;
@synthesize lbUsername;
@synthesize viGive;
@synthesize btGive;
@synthesize lbMaxPrice;
@synthesize lbDescription;
@synthesize ivFeed;
@synthesize lbPostTime;
@synthesize lbGiveTitle;
@synthesize progressView;
@synthesize btHeart;
@synthesize ivGave;
@synthesize ivCountry;
@synthesize lbCountry;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initUI
{
    lbMaxPrice.numberOfLines = 1;
    lbMaxPrice.adjustsFontSizeToFitWidth = YES;
    [lbMaxPrice setMinimumScaleFactor:7.0/[UIFont labelFontSize]];

    ivFeed.userInteractionEnabled = YES;
    UITapGestureRecognizer* gesturePhoto = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapPhoto)];
    gesturePhoto.numberOfTapsRequired = 1;
    [ivFeed addGestureRecognizer: gesturePhoto];
    
    lbUsername.userInteractionEnabled = YES;
    UITapGestureRecognizer* gestureUsername = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapUsername)];
    gestureUsername.numberOfTapsRequired = 1;
    [lbUsername addGestureRecognizer: gestureUsername];
    
    ivUserAvatar.layer.cornerRadius = ivUserAvatar.frame.size.width / 2.0;
    ivUserAvatar.layer.masksToBounds = YES;
    ivUserAvatar.userInteractionEnabled = YES;
    UITapGestureRecognizer* gestureAvatar = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapUsername)];
    gestureAvatar.numberOfTapsRequired = 1;
    [ivUserAvatar addGestureRecognizer: gestureAvatar];
    
    btGive.layer.cornerRadius = btGive.frame.size.width / 2.0;
    btGive.layer.masksToBounds = YES;
    
    ivFeed.layer.masksToBounds = YES;
    ivFeed.contentMode = UIViewContentModeScaleAspectFill;

    progressView.trackBackgroundColor = [UIColor whiteColor];
    progressView.trackBorderColor = [UIColor whiteColor];
    progressView.trackFillColor = [UIColor colorWithRed: 234.0/255.0 green: 157.0/255.0 blue: 13.0/255.0 alpha: 1.0];
    
    if(currentFeed.country_code!=nil){
        CountryUtils* countryUtils = [[CountryUtils alloc] init];
        ivCountry.hidden = NO;
        lbCountry.hidden = NO;
        lbCountry.text = [countryUtils getCountryNameByCode:currentFeed.country_code];
        [ivCountry setImage: [UIImage imageNamed: [currentFeed.country_code lowercaseString]]];
    }else{
        ivCountry.hidden = YES;
        lbCountry.hidden = YES;
    }
}

- (void) setDonateFeed: (Feed*) f isDetail: (BOOL) isDetail
{
    currentFeed = f;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self initUI];
    
    NSURL* urlPhoto = [NSURL URLWithString: f.getProjectImage];
    [ivFeed sd_setImageWithURL: urlPhoto];
    
    if(currentFeed.videoURL == nil){
        _ivPlayVideo.hidden = YES;
    }else{
        _ivPlayVideo.hidden = NO;
    }
    
    lbDescription.text = f.feed_description;
    
    lbMaxPrice.text = [NSString stringWithFormat: @"$%d", f.pre_amount/100];
    float progress = (float)(f.donated_amount/100) / (float)(f.pre_amount/100);
    if(progress > 1) progress = 1;
    progressView.progress = progress;
    
    //User.
    lbUsername.text = [AppEngine getValidString: f.postUser.name];
    lbPostTime.text = [AppEngine dataTimeStringFromDate:f.created_at];
    [ivUserAvatar sd_setImageWithURL: [NSURL URLWithString: f.postUser.avatar] placeholderImage: [UIImage imageNamed: @"default-profile-pic.png"]];

    lbGiveTitle.hidden = NO;
    
    if(f.donated_amount >= f.pre_amount)
    {
        lbMaxPrice.hidden = YES;
    
        if([f.getFeedType isEqualToString:FEED_TYPE_MONTHLY]){
            lbGiveTitle.text = @"MONTH";
            [lbGiveTitle setFont:[UIFont systemFontOfSize:7]];
            lbGiveTitle.hidden = NO;
        }else{
            lbGiveTitle.hidden = YES;
        }

        
        [btGive setTitle: @"FUNDED!" forState: UIControlStateNormal];
    }
    else
    {
        lbMaxPrice.hidden = NO;
        lbGiveTitle.hidden = NO;
        [btGive setTitle: @"" forState: UIControlStateNormal];
     
        if([f.getFeedType isEqualToString:FEED_TYPE_MONTHLY]){
            lbGiveTitle.text = @"LEFT/\nMONTH";
            [lbGiveTitle setFont:[UIFont systemFontOfSize:7]];
        }else{
            lbGiveTitle.text = @"LEFT";
            [lbGiveTitle setFont:[UIFont systemFontOfSize:10]];
        }
        
        if (f.donated_amount == 0) {
            lbMaxPrice.text = [NSString stringWithFormat: @"$%d", f.pre_amount/100];
        } else {
            lbMaxPrice.text = [NSString stringWithFormat: @"$%d", (f.pre_amount/100 - f.donated_amount/100)];
        }
        
    }
    
    
    //Heart.
    btHeart.hidden = NO;
    if(currentFeed.postUser.user_id == [AppEngine sharedInstance].currentUser.user_id)
    {
        btHeart.hidden = YES;
    }
    else
    {
        
        UIImage* imgHeart = [UIImage imageNamed: @"heart.png"];
        if(currentFeed.postUser.followed)
        {
            imgHeart = [UIImage imageNamed: @"heart_sel.png"];

        }
        [btHeart setImage: imgHeart forState: UIControlStateNormal];
    }
    
    //Gave.
    ivGave.hidden = !currentFeed.is_gave;
}

- (void) updateFollowStatusWithUser:(User *)selectedUser {
    //Heart.
    btHeart.hidden = NO;
    if([AppEngine sharedInstance].currentUser == nil || selectedUser.user_id == [AppEngine sharedInstance].currentUser.user_id)
    {
        btHeart.hidden = YES;
    }
    else
    {
        
        UIImage* imgHeart = [UIImage imageNamed: @"heart.png"];
        if(selectedUser.followed)
        {
            imgHeart = [UIImage imageNamed: @"heart_sel.png"];
            
        }
        [btHeart setImage: imgHeart forState: UIControlStateNormal];
    }
}

- (void) updateFollowStatus:(BOOL) followed {
    
    currentFeed.postUser.followed = followed;
    
    UIImage* imgHeart = [UIImage imageNamed: @"heart.png"];
    if(followed)
    {
        imgHeart = [UIImage imageNamed: @"heart_sel.png"];
        
    }
    [btHeart setImage: imgHeart forState: UIControlStateNormal];
}


- (IBAction) actionShare:(id)sender
{
    [self openShareProjectPopUp];
}

- (void) openShareProjectPopUp
{
    if ([self.delegate respondsToSelector:@selector(shareFeed:image:)])
    {
        [self.delegate shareFeed: currentFeed image: ivFeed.image];
    }

}

- (IBAction) actionDonate:(id)sender
{
//    if([[AppEngine sharedInstance].currentUser.fb_id isEqual: currentFeed.post_user_id]) return;
    
    if ([self.delegate respondsToSelector:@selector(donateFeed:)])
    {
        [self.delegate donateFeed: currentFeed];
    }
}

- (IBAction)playVideoClick:(id)sender {
    [self.delegate openPlayer:currentFeed.videoURL];
}

- (void) onTapPhoto
{
    if ([self.delegate respondsToSelector:@selector(selectFeed:)])
    {
        [self.delegate selectFeed: currentFeed];
    }
}

- (void) onTapUsername
{
    if ([self.delegate respondsToSelector:@selector(selectUser:)])
    {
        [self.delegate selectUser: currentFeed.postUser];
    }
}

- (IBAction) actionFollow:(id)sender
{
    if(currentFeed.postUser.followed)
    {
        if ([self.delegate respondsToSelector:@selector(unfollowUser:)])
        {
            [self.delegate unfollowUser: currentFeed.postUser];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(followUser:)])
        {
            [self.delegate followUser: currentFeed.postUser];
        }
    }
}

+ (CGFloat) getHeight
{
    return 453.0;
}

@end
