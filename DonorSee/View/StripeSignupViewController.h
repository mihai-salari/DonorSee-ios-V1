//
//  StripeSignupViewController.h
//  DonorSee
//
//  Created by Keval on 18/08/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "BaseViewController.h"

@interface StripeSignupViewController : BaseViewController

@property (nonatomic, strong) NSString *webUrl;

@property (nonatomic, copy) void (^didDismiss)(NSString *data);

@end
