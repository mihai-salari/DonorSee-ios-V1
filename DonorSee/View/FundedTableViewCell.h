#import <UIKit/UIKit.h>
#import "Event.h"

@protocol FundedTableViewCellDelegate <NSObject>
@optional
- (void) selectFeed: (Feed *) f;
@end

@interface FundedTableViewCell : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (weak, nonatomic) IBOutlet UITextView *tvDescription;
@property (weak, nonatomic) IBOutlet UILabel *lbInfo;

@property (retain, nonatomic) Event      *currentFeed;
@property (nonatomic, retain) id        delegate;
- (void) setDonateFeed: (Event*) f;

@end