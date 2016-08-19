//
//  UploadTableViewCell.m
//  DonorSee
//
//  Created by star on 3/4/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "UploadTableViewCell.h"
#import "JAmazonS3ClientManager.h"

@implementation UploadTableViewCell
@synthesize lbDescription;
@synthesize ivPhoto;
@synthesize btSmall1;
@synthesize btSmall2;
@synthesize btBig;
@synthesize lbInfo;
@synthesize viButtons;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initUI
{
    ivPhoto.layer.masksToBounds = YES;
    ivPhoto.userInteractionEnabled = YES;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapPhoto)];
    gesture.numberOfTapsRequired = 1;
    [ivPhoto addGestureRecognizer: gesture];
    
    btSmall1.layer.masksToBounds = YES;
    btSmall1.layer.cornerRadius = 5.0;
    btSmall1.layer.borderWidth = 1;
    btSmall1.layer.borderColor = COLOR_MAIN.CGColor;
    
    btSmall2.layer.masksToBounds = YES;
    btSmall2.layer.cornerRadius = 5.0;
    btSmall2.layer.borderWidth = 1;
    btSmall2.layer.borderColor = COLOR_MAIN.CGColor;
    
    btBig.layer.masksToBounds = YES;
    btBig.layer.cornerRadius = 5.0;
    btBig.layer.borderWidth = 1;
    btBig.layer.borderColor = COLOR_MAIN.CGColor;
    
    self.backgroundColor = [UIColor clearColor];
    
    lbDescription.customSelectionColor = [UIColor colorWithRed: 94.0/255.0 green: 94.0/255.0 blue: 94.0/255.0 alpha: 1.0];
    lbDescription.fontText = [UIFont fontWithName: FONT_LIGHT size: 12.0];
    lbDescription.fontUsername = [UIFont fontWithName: FONT_MEDIUM size: 12.0];
    [lbDescription updateTextAttribute];
    
    if(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS)
    {
        btSmall1.titleLabel.font = [UIFont fontWithName: FONT_LIGHT size: 10.0];
        btSmall2.titleLabel.font = [UIFont fontWithName: FONT_LIGHT size: 10.0];
    }
}

- (void) setFeed: (Feed*) f isOther: (BOOL) isOther
{
    [self setFeed: f];
    viButtons.hidden = YES;
    lbDescription.frame = CGRectMake(lbDescription.frame.origin.x,
                                     lbInfo.frame.origin.y + lbInfo.frame.size.height + 12.0,
                                     lbDescription.frame.size.width,
                                     viButtons.frame.origin.y + viButtons.frame.size.height - 5.0);
}

- (void) setFeed: (Feed*) f
{
    [self initUI];
    
    currentFeed = f;

    //Change Progress.
    int preAmount = f.pre_amount;
    int donatedAmount = f.donated_amount;
    float progress = (float)donatedAmount / (float)preAmount;
    if(progress < 0) progress = 0;
    if(progress > 1) progress = 1;
    
    lbInfo.text = [NSString stringWithFormat: @"%d%@ RAISED", (int)(progress * 100), @"%"];
    
    NSArray* donatedUserNames = [f getDonatedUsernames];
    DONATED_STATUS status = [f getDonatedStatus];
    if(status == FULL_DONATED)
    {
        lbDescription.text = [NSString stringWithFormat: @"You have received funds from %@. Don't forget to email them a follow up picture!", [self getUsernameString: donatedUserNames]];
//        [btBig setTitle: @"Email Follow Up Picture" forState: UIControlStateNormal];
//        btBig.hidden = NO;
//        btSmall1.hidden = YES;
//        btSmall2.hidden = YES;
    }
    else if(status == DONATING)
    {
        lbDescription.text = [NSString stringWithFormat: @"You have received funds from %@. Don't forget to email them a follow up picture!", [self getUsernameString: donatedUserNames]];
//        btBig.hidden = YES;
//        btSmall1.hidden = NO;
//        btSmall2.hidden = NO;
    }
    else
    {
        lbDescription.text = @"No donations have been made to this project yet.";
//        [btBig setTitle: @"Share Your Project" forState: UIControlStateNormal];
//        btBig.hidden = NO;
//        btSmall1.hidden = YES;
//        btSmall2.hidden = YES;
    }

    [ivPhoto sd_setImageWithURL: [NSURL URLWithString: f.photo]];
    [lbDescription setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range)
     {
         if(hotWord == STTweetCustom)
         {
             NSArray* donatedUserNames = [f getDonatedUsernames];
             if(donatedUserNames != nil)
             {
                 NSString* text = lbDescription.text;
                 int index = 0;
                 for(NSString* name in donatedUserNames)
                 {
                     NSRange subRange = [text rangeOfString: name];
                     if(range.location == subRange.location && range.length == subRange.length)
                     {
                         User* u = [f getUserInfo: index];
                         if ([self.delegate respondsToSelector:@selector(selectUser:)])
                         {
                             [self.delegate selectUser: u];
                         }
                         return;
                     }
                     
                     index ++;
                 }
             }

         }
     }];
}

- (NSString*) getUsernameString: (NSArray*) array
{
    NSString* result = @"";
    
    for(NSString* username in array)
    {
        NSString* filterUsername = [username stringByReplacingOccurrencesOfString: @" " withString: @"@"];
        if([result length] == 0)
        {
            result = [NSString stringWithFormat: @"!%@", filterUsername];
        }
        else
        {
            result = [result stringByAppendingString: [NSString stringWithFormat: @", !%@", filterUsername]];
        }
    }
    return result;
}

- (void) updateButtonStatus
{
    
}

- (IBAction) actionBigButton:(id)sender
{
    DONATED_STATUS status = [currentFeed getDonatedStatus];
    if(status == FULL_DONATED)
    {
        [self actionEmail: nil];
    }
    else
    {
        [self actionShareProject: nil];
    }
}

- (IBAction) actionShareProject:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(shareFeed:image:)])
    {
        [self.delegate shareFeed: currentFeed image: ivPhoto.image];
    }
}

- (IBAction) actionEmail:(id)sender
{
    NSMutableArray* arrEmails = [[NSMutableArray alloc] init];
    if(currentFeed.arrUsers != nil && [currentFeed.arrUsers count] > 0)
    {
        for(User* u in currentFeed.arrUsers)
        {
            if(u.email != nil)
            {
                [arrEmails addObject: u.email];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(emailFeed:array:)])
    {
        [self.delegate emailFeed: currentFeed array: arrEmails];
    }
}

- (IBAction) actionFollow:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(followFeed:)])
    {
        [self.delegate followFeed: currentFeed];
    }
}

- (void) onTapPhoto
{
    if ([self.delegate respondsToSelector:@selector(selectFeed:)])
    {
        [self.delegate selectFeed: currentFeed];
    }
}

+ (CGFloat) getHeight
{
    return 145.0;
}

@end
