//
//  AuthView.m
//  DonorSee
//
//  Created by star on 3/21/16.
//  Copyright © 2016 DonorSee LLC. All rights reserved.
//

#import "AuthView.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation AuthView
@synthesize viStep1;
@synthesize scMain;
@synthesize tfEmail;
@synthesize tfPassword;

@synthesize viStep2;
@synthesize lbAuthThanks;
@synthesize ivProfileImage;
@synthesize btAuthNext;
@synthesize viStep3;
@synthesize tfPaypalEmail;
@synthesize btPaypalNext;

- (void) initUI
{
    ivProfileImage.layer.masksToBounds = YES;
    ivProfileImage.layer.cornerRadius = ivProfileImage.frame.size.width / 2.0;
    ivProfileImage.contentMode = UIViewContentModeScaleAspectFill;
    
    btAuthNext.layer.masksToBounds = YES;
    btAuthNext.layer.cornerRadius = 20.0;
    
    btPaypalNext.layer.masksToBounds = YES;
    btPaypalNext.layer.cornerRadius = 20.0;
}

- (void) updateInfo
{
    lbAuthThanks.text = [NSString stringWithFormat: @"Thank you for signing in %@!", [AppEngine sharedInstance].currentUser.name];
    [ivProfileImage sd_setImageWithURL: [NSURL URLWithString: [AppEngine sharedInstance].currentUser.avatar] placeholderImage: [UIImage imageNamed: @"default-profile-pic.png"]];
    
    viStep1.hidden = NO;
    viStep2.hidden = YES;
    viStep3.hidden = YES;
}

- (id) initAuthView: (CGRect) frame parentView: (id) parentView delegate: (id) delegate
{
    if(self = [super initWithFrame: frame])
    {
        AuthView* xibView = [[[NSBundle mainBundle] loadNibNamed:@"AuthView" owner:self options:nil] objectAtIndex:0];
        [xibView setFrame:frame];
        self = xibView;

        self.delegate = delegate;
        parentViewController = parentView;
        [self initUI];
        [self updateInfo];
    }
    return self;
}

- (IBAction) actionSignInFB:(id)sender
{
    [self signInFB:^{
        
        [self gotoStep2];

    } failure:^{
        
        if ([self.delegate respondsToSelector:@selector(successAuth)])
        {
            [self.delegate failAuth];
        }
        
    }];
}

- (IBAction) actionSignIn:(id)sender
{
    NSString* email = tfEmail.text;
    NSString* password = tfPassword.text;
    
    if(email == nil || [email length] == 0 || ![AppEngine emailValidate: email])
    {
        [parentViewController presentViewController: [AppEngine showAlertWithText: MSG_INVALID_EMAIL] animated: YES completion: nil];
        return;
    }
    
    if(password == nil || [password length] <= PASSWORD_MAX_LENGTH)
    {
        [parentViewController presentViewController: [AppEngine showAlertWithText: MSG_INVALID_PASSWORD] animated: YES completion: nil];
        return;
    }
    
    [SVProgressHUD showWithStatus: @"Log in..." maskType: SVProgressHUDMaskTypeClear];
    [[NetworkClient sharedClient] login: email
                               password: password
                                success:^(NSDictionary *dicUser) {
                                    
                                    [SVProgressHUD dismiss];
                                    
                                    User* u = [[User alloc] initUserWithDictionary: dicUser];
                                    
                                    [[CoreHelper sharedInstance] addUser: u];
                                    [[CoreHelper sharedInstance] setCurrentUserId: u.user_id];
                                    [AppEngine sharedInstance].currentUser = u;
                                    
                                    [self gotoStep2];
                                    
                                } failure:^(NSString *errorMessage) {
                                    [SVProgressHUD dismiss];
                                    [parentViewController presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                }];

}

#pragma mark Step 2

- (void) gotoStep2
{
    [self updateInfo];
    
    viStep1.hidden = YES;
    viStep2.hidden = NO;
}

- (IBAction) actionNext:(id)sender
{
    viStep1.hidden = YES;
    viStep2.hidden = YES;
    
//    if(isAskingPaypal)
//    {
//        viStep3.hidden = NO;
//    }
//    else
//    {
        [self goBackAuth];
//    }
}

- (void) goBackAuth
{
    self.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(successAuth)])
    {
        [self.delegate successAuth];
    }
}

- (IBAction) actionForgotPassword:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Forgot Password" message: @"Please type your email address." preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //Do Some action here
                                                   UITextField *textField = alert.textFields[0];
                                                   NSLog(@"text was %@", textField.text);
                                                   
                                                   NSString* email = textField.text;
                                                   if(email == nil && [AppEngine emailValidate: email])
                                                   {
                                                       [parentViewController presentViewController: [AppEngine showErrorWithText: MSG_INVALID_EMAIL]
                                                                          animated: YES
                                                                        completion: nil];
                                                       return;
                                                   }
                                                   
                                                   [SVProgressHUD showWithMaskType: SVProgressHUDMaskTypeClear];
                                                   [[NetworkClient sharedClient] forgotPassword: email
                                                                                        success:^(NSDictionary *responseObject) {
                                                                                            
                                                                                            [SVProgressHUD dismiss];
                                                                                            NSLog(@"url = %@", [responseObject valueForKey: @"url"]);
                                                                                            NSString* message = [responseObject valueForKey: @"message"];
                                                                                            [parentViewController presentViewController: [AppEngine showMessage: message
                                                                                                                                          title: nil]
                                                                                                               animated: YES
                                                                                                             completion: nil];
                                                                                            
                                                                                            
                                                                                        } failure:^(NSError *error) {
                                                                                            NSLog(@"error = %@", error);
                                                                                            [SVProgressHUD dismiss];
                                                                                        }];
                                                   
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                       
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Email";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    [parentViewController presentViewController:alert animated:YES completion:nil];
}


- (IBAction) actionPaypalNext:(id)sender
{
    NSString* paypalEmail = tfPaypalEmail.text;
    if(paypalEmail == nil || ![AppEngine emailValidate: paypalEmail])
    {
        [parentViewController presentViewController: [AppEngine showAlertWithText: MSG_INVALID_PAYPAL_EMAIL] animated: YES completion: nil];
        return;
    }
    
    [SVProgressHUD showWithMaskType: SVProgressHUDMaskTypeClear];
    [[NetworkClient sharedClient] addPaypal: paypalEmail
                                    success:^{
                                       
                                        [SVProgressHUD dismiss];
                                        [AppEngine sharedInstance].currentUser.paypal = paypalEmail;
                                        [[CoreHelper sharedInstance] addPaypal: [AppEngine sharedInstance].currentUser paypal:paypalEmail];
                                        [self goBackAuth];
                                        
                                    } failure:^(NSString *errorMessage) {
                                        
                                        [SVProgressHUD dismiss];
                                        [parentViewController presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                        
                                    }];
}

- (void) signInFB: (void (^)(void)) completed failure: (void (^)(void)) failure
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [login logInWithReadPermissions: @[@"public_profile", @"email"]
                 fromViewController: parentViewController
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
     {
         if (error)
         {
             [parentViewController presentViewController: [AppEngine showErrorWithText: error.description] animated: YES completion: nil];
             failure();
         }
         else if (result.isCancelled)
         {
             NSLog(@"Cancelled");
             failure();
         }
         else
         {
             NSLog(@"Logged in");
             if ([FBSDKAccessToken currentAccessToken])
             {
                 [SVProgressHUD showWithStatus: @"Sign in with Facebook..."];
                 
                 NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                 [parameters setValue:@"id, name, email" forKey:@"fields"];
                 
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters: parameters]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                  {
                      if (!error)
                      {
                          NSLog(@"fetched user:%@", result);
                          NSString* fbId = [result valueForKey: @"id"];
                          NSString* name = [result valueForKey: @"name"];
                          NSString* email = [result valueForKey: @"email"];
                          
                          [[NetworkClient sharedClient] loginWithFB: fbId
                                                               name: name
                                                              email: email
                                                            success:^(NSDictionary *dicUser) {
                                                                
                                                                [SVProgressHUD dismiss];
                                                                User* u = [[User alloc] initUserWithDictionary: dicUser];
                                                                
                                                                [[CoreHelper sharedInstance] addUser: u];
                                                                [[CoreHelper sharedInstance] setCurrentUserId: u.user_id];
                                                                [AppEngine sharedInstance].currentUser = u;
                                                                
                                                                completed();
                                                                
                                                            } failure:^(NSString *errorMessage) {
                                                                
                                                                [SVProgressHUD dismiss];
                                                                [parentViewController presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                                                
                                                                failure();
                                                            }];
                      }
                      else
                      {
                          [SVProgressHUD dismiss];
                          [parentViewController presentViewController: [AppEngine showErrorWithText: error.description]
                                             animated: YES
                                           completion: nil];
                          
                          failure();
                      }
                  }];
             }
         }
     }];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == tfEmail)
    {
        [tfPassword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == tfEmail)
    {
        [scMain setContentOffset: CGPointMake(0, 60) animated: YES];
    }
    else if(textField == tfPassword)
    {
        [scMain setContentOffset: CGPointMake(0, 120) animated: YES];
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [scMain setContentOffset: CGPointZero animated: YES];
}

@end
