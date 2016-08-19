//
//  StripeDonateViewController.h
//  DonorSee
//
//  Created by Keval on 11/06/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "BaseViewController.h"

@class StripeDonateViewController;

@protocol StripePaymentViewControllerDelegate<NSObject>

@optional
- (void)paymentViewController:(StripeDonateViewController *)controller didFinish:(NSError *)error;
- (void)paymentViewController:(StripeDonateViewController *)controller didCompletedWithToken:(NSString *)token;

@end

@interface StripeDonateViewController : BaseViewController

@property (nonatomic) NSDecimalNumber *amount;

@property (nonatomic, weak) id<StripePaymentViewControllerDelegate> delegate;

@end
