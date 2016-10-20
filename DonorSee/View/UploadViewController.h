//
//  UploadViewController.h
//  DonorSee
//
//  Created by star on 2/29/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "Feed.h"

@interface UploadViewController : BaseViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIButton *BtnUpdateProject;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property(nonatomic,assign) BOOL isUpdateMode;
@property(nonatomic,retain) Feed *objFeed;

- (IBAction)UpdateButtonPress:(UIButton *)sender;
- (IBAction)CancelButtonPress:(UIButton *)sender;

- (void) captureImage: (UIImage*) image;
@end
