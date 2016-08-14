//
//  SettingsTableViewCell.m
//  DonorSee
//
//  Created by star on 3/18/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "SettingsTableViewCell.h"

@implementation SettingsTableViewCell
@synthesize ivIcon;
@synthesize lbTitle;
@synthesize swType;

@synthesize constraintTitleLeft;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat) getHeight
{
    return 57.0;
}

- (void) setItem: (NSDictionary*) dicItem isShowDonatedAmount: (BOOL) isShow
{
    NSString* icon = dicItem[@"icon"];
    NSString* title = dicItem[@"title"];
    
    if(icon != nil && [icon length] > 0)
    {
        swType.hidden = YES;
        ivIcon.hidden = NO;
        ivIcon.image = [UIImage imageNamed: icon];
        constraintTitleLeft.constant = 13.0;
    }
    else
    {
        swType.on = isShow;
        swType.hidden = NO;
        ivIcon.hidden = YES;
        constraintTitleLeft.constant = -30.0;
    }
    
    [self layoutIfNeeded];
    lbTitle.text = title;
}


- (IBAction) actionValueChanged:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changedShowDonatedAmount:)])
    {
        [self.delegate changedShowDonatedAmount: swType.on];
    }
}

@end
