//
//  FollowUpViewController.h
//  DonorSee
//
//  Created by Bogdan on 10/15/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FollowUpViewControllerDelegate <NSObject>
@optional
- (void) onFollowUpPostedSuccess;
@end

@interface FollowUpViewController : UIViewController <UIAdaptivePresentationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) Feed *selectedFeed;
@property (nonatomic, weak) id<FollowUpViewControllerDelegate> delegate;

@end
