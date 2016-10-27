//
//  LoginViewController.m
//  DonorSee
//
//  Created by star on 4/8/16.
//  Copyright © 2016 miroslave. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () <UITextFieldDelegate>
{
    
}
@property (nonatomic, weak) IBOutlet UIScrollView       *scMain;
@property (nonatomic, weak) IBOutlet UIButton           *btLogin;
@property (nonatomic, weak) IBOutlet UITextField        *tfEmail;
@property (nonatomic, weak) IBOutlet UITextField        *tfPassword;

@end

@implementation LoginViewController
@synthesize scMain;
@synthesize btLogin;
@synthesize tfEmail;
@synthesize tfPassword;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initMember
{
    [super initMember];
    
    btLogin.layer.masksToBounds = YES;
    btLogin.layer.cornerRadius = 20.0;
    btLogin.layer.borderColor = [UIColor whiteColor].CGColor;
    btLogin.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped)];
    tapScroll.cancelsTouchesInView = NO;
    [scMain addGestureRecognizer:tapScroll];
}

- (void) tapped
{
    [self.view endEditing:YES];
}

- (void) hideKeyboard
{
    [tfEmail resignFirstResponder];
    [tfPassword resignFirstResponder];
}

- (IBAction) actionLogin:(id)sender
{
    [self hideKeyboard];
    
    NSString* email = tfEmail.text;
    NSString* password = tfPassword.text;
    
    if(email == nil || [email length] == 0 || ![AppEngine emailValidate: email])
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_EMAIL] animated: YES completion: nil];
        return;
    }
    
    if(password == nil || [password length] <= PASSWORD_MAX_LENGTH)
    {
        [self presentViewController: [AppEngine showAlertWithText: MSG_INVALID_PASSWORD] animated: YES completion: nil];
        return;
    }
    
    [SVProgressHUD showWithStatus: @"Log in..." maskType: SVProgressHUDMaskTypeClear];
    [[NetworkClient sharedClient] login: email
                               password: password
                                 success:^(NSDictionary *dicUser) {
                                     
                                     [SVProgressHUD dismiss];
                                     
                                     FEMMapping *mapping = [DSMappingProvider userMapping];
                                     User *u = [FEMDeserializer objectFromRepresentation:dicUser mapping:mapping];
                                     
//                                     u.user_id = 16;
//                                     u.email = @"gglyer@yahoo.com";
//                                     u.name = @"Gret Glyer";
                                     
                                     [[CoreHelper sharedInstance] addUser: u];
                                     [[CoreHelper sharedInstance] setCurrentUserId: u.user_id];
                                     [AppEngine sharedInstance].currentUser = u;
                                     
                                     if (self.isModal) {
                                         NSLog(@"Presented in Model");
                                         [[NSNotificationCenter defaultCenter]
                                          postNotificationName:@"LOGIN_COMPLETE"
                                          object:nil userInfo:@{@"status":@"1"}];
                                         
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     } else {
                                         [self gotoHomeView: YES];
                                     }
                                     
                                     
                                     
                                 } failure:^(NSString *errorMessage) {
                                     [SVProgressHUD dismiss];
                                     [self presentViewController: [AppEngine showErrorWithText: errorMessage] animated: YES completion: nil];
                                 }];
}

- (IBAction) actionFBSignIn:(id)sender
{
    [self signInFB:^{
        if (self.isModal) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"LOGIN_COMPLETE"
             object:nil userInfo:@{@"status":@"1"}];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self gotoHomeView: YES];
        }
    }];
}

- (void) showEnterPinForEmail:(NSString *)email {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"PIN Verification" message: @"Please enter PIN and new password" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //Do Some action here
                                                   UITextField *textField = alert.textFields[0];
                                                   NSLog(@"text was %@", textField.text);
                                                   
                                                   NSString* email = textField.text;
                                                   if(email == nil && [AppEngine emailValidate: email])
                                                   {
                                                       [self presentViewController: [AppEngine showErrorWithText: MSG_INVALID_EMAIL]
                                                                          animated: YES
                                                                        completion: nil];
                                                       return;
                                                   }
                                                   
                                                   UITextField *pintextField = alert.textFields[1];
                                                   
                                                   if (pintextField.text.length == 0) {
                                                       [self presentViewController: [AppEngine showErrorWithText: @"Enter a valid PIN"]
                                                                          animated: YES
                                                                        completion: nil];
                                                       return;
                                                   }
                                                   
                                                   UITextField *passwordtextField = alert.textFields[2];
                                                   
                                                   if (passwordtextField.text.length == 0) {
                                                       [self presentViewController: [AppEngine showErrorWithText: @"Enter a valid password"]
                                                                          animated: YES
                                                                        completion: nil];
                                                       return;
                                                   }
                                                   
                                                   [SVProgressHUD showWithMaskType: SVProgressHUDMaskTypeClear];
                                                   [[NetworkClient sharedClient] verifyPin:pintextField.text newPassword:passwordtextField.text email:email success:^(NSDictionary *responseObject) {
                                                       [SVProgressHUD dismiss];
                                                       
                                                       [self presentViewController: [AppEngine showErrorWithText: @"Password changed successfully"]
                                                                          animated: YES
                                                                        completion: nil];
                                                       
                                                   } failure:^(NSString *errorMessage) {
                                                       [SVProgressHUD dismiss];
                                                       [self presentViewController: [AppEngine showErrorWithText: errorMessage]
                                                                          animated: YES
                                                                        completion: nil];
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
        textField.text = email;
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"PIN";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"New password";
        textField.keyboardType = UIKeyboardTypeDefault;
    }];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction) actionForgotPassword:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Forgot Password" message: @"Please type your email address to request new PIN." preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //Do Some action here
                                                   UITextField *textField = alert.textFields[0];
                                                   NSLog(@"text was %@", textField.text);
                                                   
                                                   NSString* email = textField.text;
                                                   if(email == nil && [AppEngine emailValidate: email])
                                                   {
                                                       [self presentViewController: [AppEngine showErrorWithText: MSG_INVALID_EMAIL]
                                                                          animated: YES
                                                                        completion: nil];
                                                       return;
                                                   }
                                                   
                                                   
                                                   [SVProgressHUD showWithMaskType: SVProgressHUDMaskTypeClear];
                                                   [[NetworkClient sharedClient] forgotPassword: email
                                                                                        success:^(NSDictionary *responseObject) {
                                                                                            
                                                                                            [SVProgressHUD dismiss];
                                                                                            [self showEnterPinForEmail:email];
                                                                                            
                                                                                        } failure:^(NSString *errorMessage) {
                                                                                            NSLog(@"error = %@", errorMessage);
                                                                                            [SVProgressHUD dismiss];
                                                                                            
                                                                                            [self presentViewController: [AppEngine showErrorWithText: errorMessage]
                                                                                                               animated: YES
                                                                                                             completion: nil];

                                                                                            
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
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextField.

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    float offset = 0;
    if(IS_IPHONE_5)
    {
        offset = 20.0;
    }
    else if(IS_IPHONE_4_OR_LESS)
    {
        offset = 60.0;
    }

    [scMain setContentOffset: CGPointMake(0, offset) animated: YES];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [scMain setContentOffset: CGPointZero animated: YES];
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

@end
