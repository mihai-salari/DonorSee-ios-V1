//
//  FundedTableViewCell.h
//  DonorSee
//
//  Created by star on 3/7/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FundedTableViewCellDelegate <NSObject>
@optional
- (void) selectFeed: (Feed*) f;
@end

@interface FundedTableViewCell : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (weak, nonatomic) IBOutlet UITextView *tvDescription;
@property (weak, nonatomic) IBOutlet UILabel *lbInfo;

@property (retain, nonatomic) Feed      *currentFeed;
@property (nonatomic, retain) id        delegate;
- (void) setDonateFeed: (Feed*) f;

@end
