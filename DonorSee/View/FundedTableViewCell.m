//
//  FundedTableViewCell.m
//  DonorSee
//
//  Created by star on 3/7/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "FundedTableViewCell.h"
#import "JAmazonS3ClientManager.h"

@implementation FundedTableViewCell
@synthesize ivPhoto;
@synthesize tvDescription;
@synthesize lbInfo;
@synthesize currentFeed;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initUI
{
    self.backgroundColor = [UIColor clearColor];
    
    ivPhoto.layer.masksToBounds = YES;
    ivPhoto.contentMode = UIViewContentModeScaleAspectFill;
    ivPhoto.userInteractionEnabled = YES;
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTapPhoto)];
    gesture.numberOfTapsRequired = 1;
    [ivPhoto addGestureRecognizer: gesture];
    
    tvDescription.textColor = [UIColor colorWithRed: 153.0/255.0 green: 153.0/255.0 blue: 153.0/255.0 alpha: 1.0];
}

- (void) setDonateFeed: (Feed*) f
{
    [self initUI];
    
    //Change Progresss
    int preAmount = f.pre_amount;
    int donatedAmount = f.donated_amount;
    float progress = (float)donatedAmount / (float)preAmount;
    if(progress < 0) progress = 0;
    if(progress > 1) progress = 1;
    
    currentFeed = f;
    [ivPhoto sd_setImageWithURL: [NSURL URLWithString: f.photo]];
    lbInfo.text = [NSString stringWithFormat: @"%d%@ RAISED", (int)(progress * 100), @"%"];
    tvDescription.text = f.feed_description;
}

- (void) onTapPhoto
{
    if ([self.delegate respondsToSelector:@selector(selectFeed:)])
    {
        [self.delegate selectFeed: currentFeed];
    }
}

@end
