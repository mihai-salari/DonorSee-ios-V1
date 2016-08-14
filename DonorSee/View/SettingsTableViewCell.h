//
//  SettingsTableViewCell.h
//  DonorSee
//
//  Created by star on 3/18/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SettingsTableViewCellDelegate <NSObject>
@optional
- (void) changedShowDonatedAmount: (BOOL) isShowDonatedAmount;
@end

@interface SettingsTableViewCell : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UIImageView    *ivIcon;
@property (weak, nonatomic) IBOutlet UILabel        *lbTitle;
@property (weak, nonatomic) IBOutlet UISwitch       *swType;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTitleLeft;
@property (nonatomic, retain) id                    delegate;

+ (CGFloat) getHeight;
- (void) setItem: (NSDictionary*) dicItem isShowDonatedAmount: (BOOL) isShow;
@end
