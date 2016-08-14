//
//  AuthView.h
//  DonorSee
//
//  Created by star on 3/21/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AuthViewDelegate <NSObject, UITextFieldDelegate>
@optional
- (void) successAuth;
- (void) failAuth;
@end

@interface AuthView : UIView <UITextFieldDelegate>
{
//    BOOL        isAskingPaypal;
    id          parentViewController;
}

@property (nonatomic, weak) IBOutlet UIView         *viStep1;
@property (nonatomic, weak) IBOutlet UITextField    *tfEmail;
@property (nonatomic, weak) IBOutlet UITextField    *tfPassword;
@property (nonatomic, weak) IBOutlet UIScrollView   *scMain;

@property (nonatomic, weak) IBOutlet UIView         *viStep2;
@property (nonatomic, weak) IBOutlet UILabel        *lbAuthThanks;
@property (nonatomic, weak) IBOutlet UIImageView    *ivProfileImage;
@property (nonatomic, weak)  IBOutlet UIButton      *btAuthNext;

@property (nonatomic, weak) IBOutlet UIView         *viStep3;
@property (nonatomic, weak) IBOutlet UITextField    *tfPaypalEmail;
@property (nonatomic, weak) IBOutlet UIButton       *btPaypalNext;

@property (nonatomic, retain) id                    delegate;

//- (id) initAuthView: (CGRect) frame isAskingPaypal: (BOOL) isPaypal parentView: (id) parentView delegate: (id) delegate;
- (id) initAuthView: (CGRect) frame parentView: (id) parentView delegate: (id) delegate;

@end
