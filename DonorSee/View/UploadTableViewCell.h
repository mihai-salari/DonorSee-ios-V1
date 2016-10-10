//
//  UploadTableViewCell.h
//  DonorSee
//
//  Created by star on 3/4/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSTTweetLabel.h"

@protocol UploadTableViewCellDelegate <NSObject>
@optional
- (void) emailFeed: (Feed*) f array: (NSArray*) arrEmails;
- (void) shareFeed: (Feed*) f image: (UIImage*) imgShare;
- (void) followFeed: (Feed*) f;
- (void) selectFeed: (Feed*) f;
- (void) selectUser: (User*) user;
- (void) openPlayer: (NSString*) videoURL;
@end

@interface UploadTableViewCell : UITableViewCell
{
    Feed                *currentFeed;
}
@property (weak, nonatomic) IBOutlet UIImageView            *ivPhoto;
@property (weak, nonatomic) IBOutlet CustomSTTweetLabel     *lbDescription;
@property (weak, nonatomic) IBOutlet UIView                 *viButtons;
@property (weak, nonatomic) IBOutlet UIButton               *btSmall1;
@property (weak, nonatomic) IBOutlet UIButton               *btSmall2;
@property (weak, nonatomic) IBOutlet UIButton               *btBig;
@property (weak, nonatomic) IBOutlet UILabel                *lbInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayVideo;

@property (strong, nonatomic) id            delegate;

- (void) setFeed: (Feed*) f;
- (void) setFeed: (Feed*) f isOther: (BOOL) isOther;
+ (CGFloat) getHeight;
@end
